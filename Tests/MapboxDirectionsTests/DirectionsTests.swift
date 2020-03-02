import XCTest
#if !SWIFT_PACKAGE
import OHHTTPStubs
import CoreLocation
@testable import MapboxDirections

let BogusToken = "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede"
let BogusCredentials = DirectionsCredentials(accessToken: BogusToken)
let BadResponse = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML><HEAD><META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
<TITLE>ERROR: The request could not be satisfied</TITLE>
</HEAD><BODY>
<H1>413 ERROR</H1>
<H2>The request could not be satisfied.</H2>
<HR noshade size="1px">
Bad request.

<BR clear="all">
<HR noshade size="1px">
<PRE>
Generated by cloudfront (CloudFront)
Request ID: RAf2XH13mMVxQ96Z1cVQMPrd-hJoVA6LfaWVFDbdN2j-J1VkzaPvZg==
</PRE>
<ADDRESS>
</ADDRESS>
</BODY></HTML>
"""

class DirectionsTests: XCTestCase {
    override func setUp() {
        // Make sure tests run in all time zones
        NSTimeZone.default = TimeZone(secondsFromGMT: 0)!
    }
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testConfiguration() {
        let directions = Directions(credentials: BogusCredentials)
        XCTAssertEqual(directions.credentials, BogusCredentials)
    }
    
    let maximumCoordinateCount = 795
    
    func testGETRequest() {
        // Bumps right up against MaximumURLLength
        let coordinates = Array(repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0), count: maximumCoordinateCount)
        let options = RouteOptions(coordinates: coordinates)
        
        let directions = Directions(credentials: BogusCredentials)
        let url = directions.url(forCalculating: options, httpMethod: "GET")
        XCTAssertLessThanOrEqual(url.absoluteString.count, MaximumURLLength, "maximumCoordinateCount is too high")
        
        let components = URLComponents(string: url.absoluteString)
        XCTAssertEqual(components?.queryItems?.count, 7)
        XCTAssertTrue(components?.path.contains(coordinates.compactMap { $0.requestDescription }.joined(separator: ";")) ?? false)
        
        let request = directions.urlRequest(forCalculating: options)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url, url)
    }
    
    func testPOSTRequest() {
        let coordinates = Array(repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0), count: maximumCoordinateCount + 1)
        let options = RouteOptions(coordinates: coordinates)
        
        let directions = Directions(credentials: BogusCredentials)
        let request = directions.urlRequest(forCalculating: options)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.query, "access_token=\(BogusToken)")
        XCTAssertNotNil(request.httpBody)
        var components = URLComponents()
        components.query = String(data: request.httpBody ?? Data(), encoding: .utf8)
        XCTAssertEqual(components.queryItems?.count, 7)
        XCTAssertEqual(components.queryItems?.first { $0.name == "coordinates" }?.value,
                       coordinates.compactMap { $0.requestDescription }.joined(separator: ";"))
    }
    
    func testKnownBadResponse() {
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/directions")
        }) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: BadResponse.data(using: .utf8)!, statusCode: 413, headers: ["Content-Type" : "text/html"])
        }
        let expectation = self.expectation(description: "Async callback")
        let one = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let two = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 2.0, longitude: 2.0))
        
        let directions = Directions(credentials: BogusCredentials)
        let opts = RouteOptions(locations: [one, two])
        directions.calculate(opts, completionHandler: { (session, result) in

            guard case let .failure(error) = result else {
                XCTFail("Expecting error, none returned.")
                return
            }
            
            XCTAssertEqual(error, .requestTooLarge)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUnknownBadResponse() {
        let message = "Enhance your calm, John Spartan."
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/directions")
        }) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: message.data(using: .utf8)!, statusCode: 420, headers: ["Content-Type" : "text/plain"])
        }
        let expectation = self.expectation(description: "Async callback")
        let one = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let two = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 2.0, longitude: 2.0))
        
        let directions = Directions(credentials: BogusCredentials)
        let opts = RouteOptions(locations: [one, two])
        directions.calculate(opts, completionHandler: { (session, result) in
            expectation.fulfill()
            
            guard case let .failure(error) = result else {
                XCTFail("Expecting an error, none returned. \(result)")
                return
            }
            
            guard case .invalidResponse(_) = error else {
                XCTFail("Wrong error type returned.")
                return
            }
                        
        })
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRateLimitErrorParsing() {
        let url = URL(string: "https://api.mapbox.com")!
        let headerFields = ["X-Rate-Limit-Interval" : "60", "X-Rate-Limit-Limit" : "600", "X-Rate-Limit-Reset" : "1479460584"]
        let response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: headerFields)
        
        let resultError = DirectionsError(code: "429", message: "Hit rate limit", response: response, underlyingError: nil)
        if case let .rateLimited(rateLimitInterval, rateLimit, resetTime) = resultError {
            XCTAssertEqual(rateLimitInterval, 60.0)
            XCTAssertEqual(rateLimit, 600)
            XCTAssertEqual(resetTime, Date(timeIntervalSince1970: 1479460584))
        } else {
            XCTFail("Code 429 should be interpreted as a rate limiting error.")
        }
    }
    
    func testDownNetwork() {
        let notConnected = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue) as! URLError
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/directions")
        }) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: notConnected)
        }
        
        let expectation = self.expectation(description: "Async callback")
        let one = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let two = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 2.0, longitude: 2.0))
        
        let directions = Directions(credentials: BogusCredentials)
        let opts = RouteOptions(locations: [one, two])
        directions.calculate(opts, completionHandler: { (session, result) in
            expectation.fulfill()
            
            guard case let .failure(error) = result else {
                XCTFail("Error expected, none returned. \(result)")
                return
            }
            
            guard case let .network(err) = error else {
                XCTFail("Wrong error type returned. \(error)")
                return
            }
            
            XCTAssertEqual(err, notConnected)
        })
        wait(for: [expectation], timeout: 2.0)
    }
}
#endif
