//
//  ViewController.swift
//  AlgorithmsViewer
//
//  Created by Jacob Raeside on 4/13/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sizeSegControl: UISegmentedControl!
    @IBOutlet weak var algorithmSegControl1: UISegmentedControl!
    @IBOutlet weak var algorithmSegControl2: UISegmentedControl!
    @IBOutlet weak var barsView: UIView!
    @IBOutlet weak var barsView2: UIView!
    
    private var bars1: [UIView] = []
    private var bars2: [UIView] = []
    
    private var numArray: [Int] = []
    private var numArray2: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if bars1.isEmpty && bars2.isEmpty {
            buildArray()
        }
    }
    
    private func buildArray() {
        let size = getSizeSegment()
        numArray = (1...size).map { _ in Int.random(in: 1...100)}
        numArray = numArray.shuffled()
        numArray2 = numArray
        setupBars(barsView, bars: &bars1, nums: numArray)
        setupBars(barsView2, bars: &bars2, nums: numArray2)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        buildArray()
    }
    
    private func getSizeSegment() -> Int {
        switch sizeSegControl.selectedSegmentIndex {
        case 0: return 16
        case 1: return 32
        case 2: return 48
        case 3: return 64
        default: return 16
        }
    }
    
    private func setupBars(_ view: UIView, bars: inout [UIView], nums: [Int]) {
        bars.forEach { $0.removeFromSuperview() }
        bars = []
        
        let barWidth = view.bounds.width / CGFloat(nums.count)
        for (i, val) in nums.enumerated() {
            let barHeight = CGFloat(val) / 100.0 * CGFloat(view.bounds.height)
            let bar = UIView(frame: CGRect(x: CGFloat(i) * barWidth, y: view.bounds.height - barHeight, width: barWidth, height: barHeight))
            bar.backgroundColor = .blue
            view.addSubview(bar)
            bars.append(bar)
        }
    }
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        sortButton.isEnabled = false
        sizeSegControl.isEnabled = false
        algorithmSegControl1.isEnabled = false
        algorithmSegControl2.isEnabled = false
        
        let alg1 = algorithmSegControl1.selectedSegmentIndex
        let alg2 = algorithmSegControl2.selectedSegmentIndex
        
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.sortArray(&self.numArray, using: alg1, updateBars: self.bars1, inView: self.barsView) {
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.sortArray(&self.numArray2, using: alg2, updateBars: self.bars2, inView: self.barsView2) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.sortButton.isEnabled = true
            self.sizeSegControl.isEnabled = true
            self.algorithmSegControl1.isEnabled = true
            self.algorithmSegControl2.isEnabled = true
        }
    }
    
    private func sortArray(_ nums: inout [Int], using algIndex: Int, updateBars bars: [UIView], inView view: UIView, completion: @escaping () -> Void) {
        defer { completion() }
        switch algIndex {
        case 0:
            self.insertionSort(&nums, updateBars: bars, inView: view)
        case 1:
            self.selectionSort(&nums, updateBars: bars, inView: view)
        case 2:
            self.quickSort(&nums, low: 0, high: nums.count - 1, updateBars: bars, inView: view)
        case 3:
            self.mergeSort(&nums, left: 0, right: nums.count - 1, updateBars: bars, inView: view)
            
        default: break
        }
    }
    
    private func updateBars(_ bars: [UIView], with nums: [Int], inView view: UIView) {
        for (i, bar) in bars.enumerated() {
            let barHeight = CGFloat(nums[i]) / 100.0 * view.bounds.height
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    bar.frame = CGRect(x: bar.frame.origin.x, y: view.bounds.height - barHeight, width: bar.frame.width, height: barHeight)
                }
            }
        }
    }
    
    private func insertionSort(_ a: inout [Int], updateBars bars: [UIView], inView view: UIView) {
        var localArray = a
        for i in 0 ..< localArray.count {
            var j = i
            while j > 0 && localArray[j-1] > localArray[j] {
                localArray.swapAt(j-1, j)
                let currentArray = localArray
                DispatchQueue.main.async {
                    self.updateBars(bars, with: currentArray, inView: view)
                }
                usleep(100000)
                j -= 1
            }
        }
        a = localArray
    }
    
    private func selectionSort(_ a: inout [Int], updateBars: [UIView], inView view: UIView) {
        var localArray = a
        for i in 0 ..< localArray.count {
            var minIndex = i
            for j in (i+1) ..< localArray.count {
                if localArray[j] < localArray[minIndex] {
                    minIndex = j
                }
            }
            if minIndex != i {
                localArray.swapAt(i, minIndex)
                let currentArray = localArray
                DispatchQueue.main.async {
                    self.updateBars(updateBars, with: currentArray, inView: view)
                }
                usleep(100000)
            }
        }
        a = localArray
    }
    
    private func quickSort(_ a: inout [Int], low: Int, high: Int, updateBars: [UIView], inView view: UIView) {
        var localArray = a
        if low < high {
            let p = partition(&localArray, low: low, high: high, bars: updateBars, inView: view)
            quickSort(&localArray, low: low, high: p - 1, updateBars: updateBars, inView: view)
            quickSort(&localArray, low: p + 1, high: high, updateBars: updateBars, inView: view)
        }
        a = localArray
    }
    
    private func partition(_ a: inout [Int], low: Int, high: Int, bars: [UIView], inView view: UIView) -> Int {
        let pivot = a[high]
        var i = low
        for j in low ..< high {
            if a[j] < pivot {
                a.swapAt(i, j)
                i += 1
                let currentArray = a
                DispatchQueue.main.async {
                    self.updateBars(bars, with: currentArray, inView: view)
                }
                usleep(100000)
            }
        }
        a.swapAt(i, high)
        let currentArray = a
        DispatchQueue.main.async {
            self.updateBars(bars, with: currentArray, inView: view)
        }
        usleep(100000)
        return i
    }
    
    private func mergeSort(_ a: inout [Int], left: Int, right: Int, updateBars: [UIView], inView view: UIView) {
        var localArray = a
        if left < right {
            let middle = (left + right) / 2
            mergeSort(&localArray, left: left, right: middle, updateBars: updateBars, inView: view)
            mergeSort(&localArray, left: middle + 1, right: right, updateBars: updateBars, inView: view)
            merge(&localArray, left: left, middle: middle, right: right, bars: updateBars, inView: view)
        }
        a = localArray
    }
    
    private func merge(_ a: inout [Int], left: Int, middle: Int, right: Int, bars: [UIView], inView view: UIView) {
        let leftArr = Array(a[left...middle])
        let rightArr = Array(a[middle + 1...right])
        
        var i = 0, j = 0, k = left
        while i < leftArr.count && j < rightArr.count {
            if leftArr[i] <= rightArr[j] {
                a[k] = leftArr[i]
                i += 1
            } else {
                a[k] = rightArr[j]
                j += 1
            }
            k += 1
            let currentArray = a
            DispatchQueue.main.async {
                self.updateBars(bars, with: currentArray, inView: view)
            }
            usleep(100000)
        }
        while i < leftArr.count {
            a[k] = leftArr[i]
            i += 1
            k += 1
        }
        
        while j < rightArr.count {
            a[k] = rightArr[j]
            j += 1
            k += 1
        }
    }
}




