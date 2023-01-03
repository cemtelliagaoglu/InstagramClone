//
//  Protocols.swift
//  InstagramClone
//
//  Created by admin on 2.01.2023.
//

import Foundation

protocol UserProfileHeaderDelegate{
    
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate{
    func handleFollowTapped(for cell: FollowCell)
    
}