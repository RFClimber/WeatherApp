//
//  ViewController.swift
//  WeatherApp
//
//  Created by mac on 7/12/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var dataSource = [ForecastWeather]()
    
    // URL 쿼리 아이템들
    // 서울 위도/경도
    private let urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: "1f85c8c422989b25b2ffd632ae910d0b"),
        URLQueryItem(name: "units", value: "metric")
    ]
    
    // MARK: - UI 생성
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 50)
        return label
    }()
    
    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        // delegate -> tableView의 여러 속성 세팅을 뷰컨에서 대신 해주겠다
        tableView.delegate = self
        // 테이블 뷰 안에 집어넣을 데이터들을 뷰컨에서 세팅해주겠다.
        tableView.dataSource = self
        // 테이블 뷰 안에 테이블 뷰 셀 등록
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        return tableView
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentWeatherData()
        fetchForecastData()
    }
    
    // MARK: - 메서드
    
    // 서버 데이터를 불러오는 메서드
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data, error == nil else  {
                print("데이터 로드 실패")
                completion(nil)
                return
            }
            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    // 현재 날씨를 가져오는 코드
    private func fetchCurrentWeatherData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }
            
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(result.main.temp))°C"
                self.tempMinLabel.text = "최소: \(Int(result.main.tempMin))°C"
                self.tempMaxLabel.text = "최고: \(Int(result.main.tempMax))°C"
            }
            
            guard let imageUrl = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png") else {
                return
                
            }
            
            if let data = try? Data(contentsOf: imageUrl) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    // 서버에서 5일간의 날씨 예보 데이터를 불러오는 메서드
    private func fetchForecastData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: ForecastWeatherResult?) in
            guard let self, let result else { return }
            
            // 콘솔에다가 데이터를 잘 불러왔는지 찍어보기
            for forecastWeather in result.list {
                print("\(forecastWeather.main)\n\(forecastWeather.dtTxt)\n\n")
            }
            
            DispatchQueue.main.async {
                self.dataSource = result.list
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func configureUI() {
        view.backgroundColor = .black
        [
            titleLabel,
            tempLabel,
            tempStackView,
            imageView,
            tableView
        ].forEach{ view.addSubview($0) }
        
        [
            tempMinLabel,
            tempMaxLabel
        ].forEach { tempStackView.addArrangedSubview($0) }
        
        
        // MARK: - 오토 레이아웃 (SnapKit)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
        }
        
        tempLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        tempStackView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempLabel.snp.bottom).offset(10)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
            $0.top.equalTo(tempStackView.snp.bottom).offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}

extension ViewController: UITableViewDelegate {
    //테이블 뷰 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}

extension ViewController: UITableViewDataSource {
    // 테이블 뷰의 인덱스패스마다 테이블 뷰 셀을 지정
    // 인덱스 패스 -> 테이블 뷰의 행과 섹션을 의미
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else { 
            return UITableViewCell()
        }
        cell.configureCell(forecastWeather: dataSource[indexPath.row])
        return cell
    }
    
    // 테이블 뷰 섹션에 행이 몇개 들어가는가 , 여기서 섹션은 없으니 행 갯수만 입력하면 된다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
}
