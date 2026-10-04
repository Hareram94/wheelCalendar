//
//  WheelCalendar.swift
//  WheelDob
//
//  Created by Hareram on 04/10/26.
//

import UIKit

//MARK: -------------------- wheel DatePickerContainerView
protocol SelectedDateDelegate: AnyObject {
    func selectAge(age:String?)
    func selectDate(date:(year: String?, month: String?, day: String?)?)
}

class WheelCalendar: UIView {

    weak var delegate: SelectedDateDelegate?

    private let triangleLayer = CAShapeLayer()
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()

    private let yearPicker = WheelDobPicker()
    private let monthPicker = WheelDobPicker()
    private let dayPicker = WheelDobPicker()
    private var selectedYear : Int?
    private var selectedMonth : String?
    private var selectedDays : Int?
        
    private var getcalendarDate: (year: String?, month: String?, day: String?) {
        didSet{
            let year:Int = Int(getcalendarDate.year ?? "") ?? 0
            let day: Int = Int(getcalendarDate.day ?? "") ?? 0
            let age =  calculateAge(birthYear: year, birthMonth: getMonthNumber(for: getcalendarDate.month ?? "") ?? 1, birthDay: day)
            self.setAttributeAgeLbl(age: age)
            delegate?.selectAge(age: "\(age)")
            delegate?.selectDate(date: getcalendarDate)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
        layoutPickers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
        layoutPickers()
        setupCenterView() // New: Setup the center view
        layoutCenterView() // New: Layout the center view
    }

    
    override func draw(_ rect: CGRect) {
            super.draw(rect)

        }
    
    private func setAttributeAgeLbl(age:Int?){
        //AppFont.semibold.size(20.0, familyName: familyManrope)
        let mainAttr = [
            .font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
            .foregroundColor: UIColor.white
        ] as [NSAttributedString.Key : Any]
        
        let ageAttr = [
            .font: UIFont.systemFont(ofSize: 28.0, weight: .semibold),
            .foregroundColor: UIColor.white
        ] as [NSAttributedString.Key : Any]
        
        let attrParts: [AttributedStringComponent] = [
            NSAttributedString(string: "Your age is ", attributes: mainAttr),
            NSAttributedString(string: "\(age ?? 0)", attributes: ageAttr)
        ]
            self.ageLable.attributedText = NSAttributedString(from: attrParts, defaultAttributes: mainAttr)
        
    }

    private func setupCenterView() {

        // Add the triangle layer to the center view's layer
        centerView.layer.addSublayer(triangleLayer)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)
        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)
    }

    private func layoutCenterView() {
        
        NSLayoutConstraint.activate([
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
            centerView.heightAnchor.constraint(equalToConstant: 100),
            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90.0),
            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            ageLable.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -10.0),
            ageLable.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.bringSubviewToFront(centerView)
        centerView.bringSubviewToFront(ageLable)
        centerView.backgroundColor = UIColor.clear
        updateTrianglePath() // Initial triangle drawing
    }

        private func updateTrianglePath() {
            let triangleHeight: CGFloat = 25
            let triangleWidth: CGFloat = 35
            let triangleX = centerView.bounds.midX
            let triangleY = CGFloat(3) // Top of the center view

            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.close()

            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor
        }


    override func layoutSubviews() {
        super.layoutSubviews()

        yearPicker.topArcShow = false
        setupCenterView() // New: Setup the center view
        layoutCenterView()
        updateTrianglePath()
    }

    private func setupPickers() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 200
        let endYear = currentYear
        
        yearPicker.values = (startYear...endYear).map { "\($0)" }
        monthPicker.values = Calendar.current.shortMonthSymbols
        dayPicker.values = (1...31).map { "\($0)" }

        [yearPicker, monthPicker, dayPicker].forEach { picker in
           
            addSubview(picker)
        }
        
        yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
        monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
        dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
        
        /*
            // Get the current date components
                let currentDate = Date()
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: currentDate)
                let currentMonth = calendar.component(.month, from: currentDate)
                let currentDay = calendar.component(.day, from: currentDate)

                // Set the year, month, and day pickers
                let startYear = currentYear - 200
                let endYear = currentYear

                yearPicker.values = (startYear...endYear).map { "\($0)" }
                monthPicker.values = Calendar.current.shortMonthSymbols
                dayPicker.values = (1...31).map { "\($0)" }

            // Set the selected index for each picker
               yearPicker.selectedIndex = currentYear - startYear
               monthPicker.selectedIndex = currentMonth - 1 // Month is 1-indexed, but array is 0-indexed
               dayPicker.selectedIndex = currentDay - 1 // Day is 1-indexed, but array is 0-indexed

    //            // Set the initial values in the getcalendarDate
    //            getcalendarDate = (year: "\(currentYear)", month: Calendar.current.shortMonthSymbols[currentMonth - 1], day: "\(currentDay)")

                // Update pickers and label
                [yearPicker, monthPicker, dayPicker].forEach { picker in
                    addSubview(picker)
                }

                yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
                monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
                dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
            */
            
        
    }
    
    
    @objc func getYearChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        self.selectedYear = Int(selectedValue)
        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
        dayPicker.values  = (1...totalDays).map { "\($0)" }
        
        getcalendarDate.year = "\(self.selectedYear ?? 0)"
    }
    
    @objc func getMonthChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        self.selectedMonth = selectedValue
        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
        dayPicker.values  = (1...totalDays).map { "\($0)" }
        
        getcalendarDate.month = self.selectedMonth
    }
    
    @objc func getDaysChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        getcalendarDate.day = selectedValue
    }
    
    
    func daysIn(month: Int, year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month

        let calendar = Calendar.current

        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }

        return 0 // fallback in case of invalid month/year
    }
    
    func monthNumber(from name: String) -> Int? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM" // For full names like "January"
        
        // Try full name first
        if let date = formatter.date(from: name.capitalized) {
            return Calendar.current.component(.month, from: date)
        }

        // Try short name like "Jan"
        formatter.dateFormat = "MMM"
        if let date = formatter.date(from: name.capitalized) {
            return Calendar.current.component(.month, from: date)
        }

        return nil
    }
    

    private func layoutPickers() {
        // Use Auto Layout for flexibility

        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            yearPicker.topAnchor.constraint(equalTo: topAnchor),
            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            yearPicker.heightAnchor.constraint(equalToConstant: 450),
            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 90.0),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 90.0),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
    }

    func getMonthNumber(for monthAbbreviation: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent behavior
        let shortMonthSymbols = dateFormatter.shortMonthSymbols.map { $0.lowercased() } // Lowercased for case-insensitivity

        // Find the index of the month abbreviation
        if let index = shortMonthSymbols.firstIndex(of: monthAbbreviation.lowercased()) {
            return index + 1 // Adding 1 because months are 1-indexed
        } else {
            return nil // Invalid abbreviation
        }
    }

    private func calculateAge(birthYear: Int, birthMonth: Int, birthDay: Int, currentYear: Int? = nil, currentMonth: Int? = nil, currentDay: Int? = nil) -> Int {
        let calendar = Calendar.current
        let now = Date()

        // Use current date components if not provided
        let currentYearProvided = currentYear ?? calendar.component(.year, from: now)
        let currentMonthProvided = currentMonth ?? calendar.component(.month, from: now)
        let currentDayProvided = currentDay ?? calendar.component(.day, from: now)

        // Create birth date
        guard let birthDate = calendar.date(from: DateComponents(year: birthYear, month: birthMonth, day: birthDay)) else {
            print("Invalid birth date")
            return 0
        }

        // Create current date
        guard let currentDate = calendar.date(from: DateComponents(year: currentYearProvided, month: currentMonthProvided, day: currentDayProvided)) else {
            print("Invalid current date")
            return 0
        }

        // Calculate age
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        return ageComponents.year ?? 0
    }

}


//MARK: ------------- PICKER CONTROLLER
class WheelDobPicker: UIControl {
    
    private var isScrolling = false
    private let scrollView = UIScrollView()
    private var itemLabels: [UILabel] = []
    private let labelSpacing: CGFloat = 5
    private let labelHeight: CGFloat = 50
    private let labelFixedWidth: CGFloat = 70
    private let centerIndicator = UIView()
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    
    var topArcShow: Bool = true {
        didSet{
            topArcLayer.isHidden = (topArcShow ? false : true)
        }
    }
    
    public var values: [String] = [] {
        didSet {
            setupItems()
            
            // Scroll to the last item after updating values
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToLastItem(animated: true)
            }
           
        }
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
//        setupCenterIndicator()
        setupTopEclipseView()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupCenterIndicator()
        setupTopEclipseView()
        setupShadow()
    }
    
    private func setupShadow() {
          // Set up shadow for the top of the control
        layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.4 // Adjust opacity
        layer.shadowOffset = CGSize(width: 0, height: -1) // Shadow offset to the top
          layer.shadowRadius = 0 // Blur radius
          // Optional: Add corner radius if needed
          layer.cornerRadius = 0
          layer.masksToBounds = false // Allow shadow outside bounds
      }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .normal //.fast
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    private func setupItems() {
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels.removeAll()
        
        for value in values {
            let label = UILabel()
            label.text = value
            label.font = .systemFont(ofSize: 18)
            label.textAlignment = .center
            label.textColor = .darkGray
            scrollView.addSubview(label)
            itemLabels.append(label)
        }
        setNeedsLayout()
    }
    
    private func setupCenterIndicator() {
        centerIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 1
        addSubview(centerIndicator)
    }
    
    private func setupTopEclipseView() {
        topArcLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 0.2
        topEclipseView.layer.addSublayer(topArcLayer)
        
        topEclipseView.backgroundColor = UIColor.clear //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 1.0)
        addSubview(topEclipseView)
        sendSubviewToBack(topEclipseView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        
        let sideInset = bounds.width / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        var xPosition: CGFloat = 0
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let radius: CGFloat = bounds.height
        
        for label in itemLabels {
            label.bounds = CGRect(x: 0, y: 0, width: labelFixedWidth, height: labelHeight)
            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: radius * (1 - cos(0)) + 40)
            
            let deltaX = label.center.x - centerX
            let angle = deltaX / radius
            let clampedAngle = angle.clamped(to: -.pi/2 ... .pi/2)
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
            
            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: arcY + 40)
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
            
            xPosition += labelFixedWidth + labelSpacing
        }
        
        scrollView.contentSize = CGSize(width: xPosition - labelSpacing, height: bounds.height)
        
//        centerIndicator.frame = CGRect(x: bounds.midX - (labelFixedWidth + 10), y: 0, width: labelFixedWidth + 10, height: bounds.height)
        
        setupTopEclipseArc()
        highlightCenterLabel()
    }
    
    private func setupTopEclipseArc() {
        let eclipseHeight: CGFloat = 150
        let eclipseWidth = bounds.width
        topEclipseView.frame = CGRect(x: 0, y: 0, width: eclipseWidth, height: eclipseHeight)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 45))
        path.addQuadCurve(to: CGPoint(x: eclipseWidth, y: 45),
                          controlPoint: CGPoint(x: eclipseWidth / 2, y: -eclipseHeight / 2))
        path.addLine(to: CGPoint(x: eclipseWidth, y: eclipseHeight))
        path.addLine(to: CGPoint(x: 0, y: eclipseHeight))
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        topEclipseView.layer.mask = mask
        
        //--------------
        let slayer = CAShapeLayer()
        let center = CGPoint(x: (topEclipseView.bounds.width / 2), y: topEclipseView.bounds.height + 10)
        let radius: CGFloat = topEclipseView.bounds.height
        let startAngle: CGFloat = 4 * .pi / 4
         let endAngle: CGFloat = 0.0
         slayer.path = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true).cgPath
        slayer.lineWidth = 150.0
        slayer.lineCap = .round
        slayer.strokeColor = UIColor(red: 0/255, green: 5/255, blue: 2/255, alpha: 1.0).cgColor //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 0.2).cgColor
        //rgba(0, 5, 2, 1)
        slayer.fillColor = UIColor.clear.cgColor
        topEclipseView.layer.addSublayer(slayer)
        
        
        //----------------- line paths
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 1))
        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 1),
                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -30))
        topArcLayer.path = arcPath.cgPath
        topEclipseView.layer.addSublayer(topArcLayer)
        
        //-------------------
        //ic_dobCurve
        

    }
    
    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for (index, label) in itemLabels.enumerated() {
            if abs(label.center.x - centerX) < (labelFixedWidth + labelSpacing) / 2 {
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
                label.numberOfLines = 2
                selectedIndex = index
            } else {
                label.textColor = UIColor.darkGray
                label.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
                label.numberOfLines = 2
            }
        }
    }
    
    private func snapToNearest() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        var closestIndex = 0
        var closestDistance = CGFloat.greatestFiniteMagnitude
        
        for (index, label) in itemLabels.enumerated() {
            let distance = abs(label.center.x - centerX)
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        let targetLabel = itemLabels[closestIndex]
        let targetOffsetX = targetLabel.center.x - scrollView.bounds.width / 2
        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    }
}

extension WheelDobPicker: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearest()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearest()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
          isScrolling = false
      }
}

extension WheelDobPicker {
    
    // Method to forcefully scroll to the last item
    func scrollToLastItem(animated: Bool = true) {
        // Prevent continuous scrolling by checking if already scrolling
        guard !isScrolling else { return }
        isScrolling = true
        // Ensure the values array is not empty
        guard !values.isEmpty else { return }
        // Calculate the position of the last label
        let lastLabelIndex = values.count - 1
        let lastLabel = itemLabels[lastLabelIndex]
        // Calculate the target offset to scroll to the last label
        let targetOffsetX = lastLabel.center.x - scrollView.bounds.width / 2
        // Ensure the offset is within the content bounds
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        let clampedOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
        
        self.scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
        
        //        // Reset scrolling flag after animation completes
        //           if !animated {
        //               isScrolling = false
        //           }
        //
    }
    
}

// MARK: - Helper Extension
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

