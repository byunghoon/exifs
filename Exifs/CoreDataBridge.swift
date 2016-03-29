//
//  CoreDataBridge.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-09.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation

struct AlbumPref {
    let scrollOffset: CGPoint // or index?
    let lastSelection: [MediaId]
}

struct CoreDataBridge {
    private(set) var pinnedAlbumIds = [AlbumId]()
    func pinAlbum(id: AlbumId) {}
    func unpinAlbum(id: AlbumId) {}
    
    private(set) var recentlyUsedAlbumIds = [AlbumId]()
    func useAlbum(id: AlbumId) {}
    
    private(set) var albumPrefs = [AlbumId : AlbumPref]()
    func saveAlbumPrefs(prefs: AlbumPref, forAlbumId id: AlbumId) {}
    
    private(set) var mediaRelations = [MediaId : [AlbumId]]()
    func relateMedia(mediaId: MediaId, toAlbum albumId: AlbumId) {}
    func unrelateMedia(mediaId: MediaId, fromAlbum albumId: AlbumId) {}
    func deleteMedia(mediaId: MediaId) {}
    
    func unassociateAlbum(id: AlbumId) {}
}
