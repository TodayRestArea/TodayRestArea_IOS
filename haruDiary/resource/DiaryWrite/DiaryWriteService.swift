

import Foundation
import Alamofire
import UIKit
import SnapKit

struct WriteDiary{
    static let shared = WriteDiary()
    
    private func makeParameter(weatherIdx : Int, contents : String, cratedAt : String) -> Parameters
    {
        return ["weatherId" : weatherIdx,
                "contents" : contents,
                "createdDate" : cratedAt
        ]
    }
    
    func saveDiary(weatherIdx : Int, contents : String, cratedAt : String , completion : @escaping(NetworkResult<Any>) -> Void) {
        let url: String = APIConstants.baseURL + APIConstants.writeDiary
        let header : HTTPHeaders = NetworkInfo.headerWithToken
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: makeParameter(weatherIdx: weatherIdx, contents: contents, cratedAt: cratedAt),
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
            dump(dataResponse)
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure: completion(.pathErr)
                
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(DiaryWriteResponse.self, from: data)
        else { return .pathErr}
        switch statusCode {
            
        case 200: return .success(decodedData)
        case 400: return .requestErr(decodedData)
        case 500: return .serverErr
        default: return .networkFail
        }
    }
}

////get
struct AnalyzeDiary
{
    static let shared = AnalyzeDiary()
    
    func getMyData(diaryId: String ,completion : @escaping (NetworkResult<Any>) -> Void)
    {
        let URL = APIConstants.baseURL + "diarys/\(diaryId)/analysis"
        let header : HTTPHeaders = NetworkInfo.headerWithToken
        print(URL)
        let dataRequest = AF.request(URL,
                                     method: .put,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure:
                completion(.pathErr)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(AnalyzeDiaryResponse.self, from: data)
        else { return .pathErr }
        switch statusCode {
        case 200: return .success(decodedData)
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
}

struct EditDiary {
    
    static let shared = EditDiary()
    private func makeParameter(weatherIdx : Int, contents : String) -> Parameters
    {
        return ["weatherId" : weatherIdx,
                "contents" : contents
        ]
    }
    
    func saveDiary(weatherIdx : Int, contents : String, diaryId : String? , completion : @escaping(NetworkResult<Any>) -> Void) {
        
        let url: String = APIConstants.baseURL +  "diarys/\(diaryId!)"
        let header : HTTPHeaders = NetworkInfo.headerWithToken
        let dataRequest = AF.request(url,
                                     method: .put,
                                     parameters: makeParameter(weatherIdx: weatherIdx, contents: contents),
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
            dump(dataResponse)
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure: completion(.pathErr)
            }
        }
        
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(DiaryWriteResponse.self, from: data)
        else { return .pathErr}
        switch statusCode {
        case 200: return .success(decodedData)
        case 400: return .requestErr(decodedData)
        case 500: return .serverErr
        default: return .networkFail
        }
    }
}


struct DeleteDiary
{
    static let shared = DeleteDiary()
    
    func getMyData(diaryId: String? ,completion : @escaping (NetworkResult<Any>) -> Void)
    {
        let URL = APIConstants.baseURL + "diarys/\(diaryId!)"
        let header : HTTPHeaders = NetworkInfo.headerWithToken
        let dataRequest = AF.request(URL,
                                     method: .delete,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure:
                completion(.pathErr)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(DiaryWriteResponse.self, from: data)
        else { return .pathErr }
        switch statusCode {
        case 200: return .success(decodedData)
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
}

class LoadingIndicator {
    static func showLoading() {
        DispatchQueue.main.async {
            // ???????????? ?????? window ?????? ??????
            guard let window = UIApplication.shared.keyWindow else { return }
            let loadingIndicatorView: UIActivityIndicatorView
            loadingIndicatorView = UIActivityIndicatorView(style: .large)
            /// ?????? UI??? ????????? ????????? indicatorView??? ????????? full??? ??????
            loadingIndicatorView.frame = window.frame
            loadingIndicatorView.color = .brown
            window.addSubview(loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        }
    }
    
    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}

class LoadingService {
    static func showLoading() {
        DispatchQueue.main.async {
            // ?????? ???????????? ????????? ?????????
            guard let window = UIApplication.shared.windows.last else { return }

            let loadingIndicatorView: UIActivityIndicatorView
            // ???????????? ?????? IndicatorView??? ?????? ?????? ????????? ??????.
            if let existedView = window.subviews.first(
                where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else { // ?????? ?????????.
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                // ????????? ?????? UI??? ???????????? ??? ??????.
                loadingIndicatorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
                let label : UILabel = {
                    let temp = UILabel()
                    temp.font = UIFont(name: "JalnanOTF", size: 18)
                    temp.text = "????????? ?????? ??? ?????????. ^^"
                    temp.numberOfLines = 0
                    temp.sizeToFit()
                    temp.textColor = .white
                    return temp
                }()
                loadingIndicatorView.addSubview(label)
                label.snp.makeConstraints{
                    $0.centerX.equalToSuperview()
                    $0.top.equalToSuperview().inset(100)
                }
                loadingIndicatorView.frame = window.frame
                loadingIndicatorView.color = .brown
                window.addSubview(loadingIndicatorView)
            }
            loadingIndicatorView.startAnimating()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView })
                .forEach { $0.removeFromSuperview() }
        }
    }
}
