//
//  MusicModel.swift
//  musicPlayerApp
//
//  Created by 林祐辰 on 2022/6/17.
//

import Foundation


struct MusicModel:Equatable,Codable {
    
    var trackName:String?
    var artistName:String?
    var previewUrl :String?
    var artworkUrl100 : String?
    
    var getPreviewMusicURL :URL?{
        get{
            URL(string: previewUrl!)!
        }
    }
    
    func getFileURL() -> URL?{
        let url = Bundle.main.url(forResource: trackName, withExtension: "mp3")!
        return url
    }

}


struct MusicDownload : Codable{
    var resultCount : Int
    var results : [MusicModel]
    
}

enum RepeatTypes {
    case NotRepeat
    case RepeatAll
    case RepeatOne
}

enum RandomTypes{
    case NotRandom
    case Random
}


var localMusic : [MusicModel] = [ MusicModel(trackName: "閣愛妳一擺", artistName: "茄子蛋"),
                                  MusicModel(trackName: "Baby Cakes", artistName: "?te"),
                                  MusicModel(trackName: "群青", artistName: "YOASOBI"),
                                  MusicModel(trackName: "一途", artistName: "King Gnu"),
                                  MusicModel(trackName: "睡不著", artistName: "?te"),
                                  MusicModel(trackName: "電火王", artistName: "美秀集團"),
                               ]


