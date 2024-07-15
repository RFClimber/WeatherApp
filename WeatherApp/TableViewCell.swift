//
//  TableViewCell.swift
//  WeatherApp
//
//  Created by mac on 7/12/24.
//

import UIKit
import SnapKit

final class TableViewCell: UITableViewCell {
    
    static let id = "TableViewCell"
    
    private let dtTxtLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    // TableView의 style과 id로 초기화를 할 때 사용하는 코드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    // 인터페이스 빌더를 통해 셀을 초기화 할 때 사용하는 코드
    // 여기서는 페이탈에러를 통해 명시적으로 인터페이스 빌더로 초기화 하지 않음을 나타냄
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(){
        contentView.backgroundColor = .black
        [
            dtTxtLabel,
            tempLabel
        ].forEach { contentView.addSubview($0) }
        
        dtTxtLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        tempLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func configureCell(forecastWeather: ForecastWeather) {
        dtTxtLabel.text = "\(forecastWeather.dtTxt)"
        tempLabel.text = "\(forecastWeather.main.temp)°C"
    }
}
