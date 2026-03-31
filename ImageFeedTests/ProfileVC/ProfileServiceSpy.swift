//
//  ProfileServiceSpy.swift
//  ImageFeed
//
//  Created by Максим on 01.04.2026.
//

@testable import ImageFeed
import Foundation

final class ProfileServiceSpy: ProfileServiceProtocol {
    var profile: Profile?
}
