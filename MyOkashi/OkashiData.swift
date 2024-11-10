//
//  OkashiData.swift
//  MyOkashi
//
//  Created by MacBook on 2023/11/23.
//

import SwiftUI

// Identifiableプロトコルを利用して、お菓子の情報をまとめる構造体
struct OkashiItem: Identifiable {
    let id = UUID()
    let name:String
    let link:URL
    let image:URL
}

// お菓子データ検索用クラス
@Observable class OkashiData {
    // JSONのデータ構造
    struct ResultJson: Codable {
        // JSONのitem内のデータ構造
        struct Item: Codable {
            // お菓子の名称
            let name: String?
            // 掲載URL
            let url: URL?
            // 画像URL
            let image: URL?
        }
        // 複数要素
        let item: [Item]?
    } // ResultJson ここまで
    
    // お菓子のリスト（Identifiableプロトコル）
    var okashiList: [OkashiItem] = []
    // クリックされたWebページのURL情報
    var okashiLink: URL?
    
    // Web API検索用メソッド　第一引数：keyword 検索したいワード
    func searchOkashi(keyword: String) {
        // デバッグエリアに出力
        print("searchOkashiメソッドで受け取った値：\(keyword)")
        
        // Taskは非同期で処理を実行できる
        Task {
            // ここから先は非同期で処理される
            // 非同期でお菓子を検索する
            await search(keyword: keyword)
        } // Task ここまで
    } // searchOkashi ここまで
    // 非同期でお菓子データを取得
    // @MainActorを使いメインスレッドで更新する
    @MainActor
    private func search(keyword: String) async {
        // お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return
        }
        
        // リクエストURLの組み立て
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r")
        else {
            return
        }
        
        // デバッグエリアに出力
        print(req_url)
        
        do {
            // リクエストURLからダウンロード
            let (data, _) = try await URLSession.shared.data(from: req_url)
            // JSONDecoderのインスタンス取得
            let decoder = JSONDecoder()
            // 受け取ったJSONデータをパース（解析）して格納
            let json = try decoder.decode(ResultJson.self, from: data)
            
            // print(json)
            
            // お菓子の情報が取得できているか確認
            guard let items = json.item else { return }
            // お菓子のリストを初期化
            okashiList.removeAll()
            
            // 取得しているお菓子の数だけ処理
            for item in items {
                // お菓子の名称、掲載URL、画像URLをアンラップ
                if let name = item.name,
                   let link = item.url,
                   let image = item.image {
                    // １つのお菓子を構造体でまとめて管理
                    let okashi = OkashiItem(name: name, link: link, image: image)
                    // お菓子の配列へ追加
                    okashiList.append(okashi)
                }
            }
            print(okashiList)
        } catch {
            // エラー処理
            print("エラーが出ました")
        }
    } // search ここまで
}
