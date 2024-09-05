//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit


final class CarouselViewController: UIViewController {
    
    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    /// Stack view to hold the progress bars (Outlet for Storyboard)
    @IBOutlet private weak var progressStackView: UIStackView!
    
    
    private var timer: Timer?
    private var progressViews: [UIProgressView] = []
    private var pageViewController: UIPageViewController?
    private var items: [CarouselItem] = []
    
    private var currentItemIndex: Int = 0 {
        didSet {
            updateProgress()
        }
    }
    
    private var autoProgressionTimer: Timer?

    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
        setupProgressStackView()
        startAutoProgression()
        setupTapGestures()
        setupSwipeDownGesture()
        updateProgress()
        
        for gesture in pageViewController?.gestureRecognizers ?? [] {
            gesture.isEnabled = false
        }
    }
    
    private func initPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        pageViewController?.setViewControllers([getController(at: currentItemIndex)], direction: .forward, animated: true)
        
        guard let theController = pageViewController else { return }
        add(asChildViewController: theController, containerView: containerView)
    }
    
    private func setupProgressStackView() {
        progressStackView.axis = .horizontal
        progressStackView.distribution = .fillEqually
        progressStackView.spacing = 8
        
        for _ in 0..<items.count {
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.progress = 0
            progressView.tintColor = .white
            progressViews.append(progressView)
            progressStackView.addArrangedSubview(progressView)
        }
        view.bringSubviewToFront(progressStackView)
    }
    
    private func startAutoProgression() {
        autoProgressionTimer?.invalidate()
        autoProgressionTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.moveToNext()
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        startAutoProgression()
    }

    private func setupTapGestures() {
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap(_:)))
        leftTapGesture.cancelsTouchesInView = false
        leftTapGesture.numberOfTapsRequired = 1
        leftTapGesture.delegate = self
        
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRightTap(_:)))
        rightTapGesture.cancelsTouchesInView = false
        rightTapGesture.numberOfTapsRequired = 1
        rightTapGesture.delegate = self
        
        let screenWidth = UIScreen.main.bounds.width
        
        let leftFrame = CGRect(x: 0, y: 0, width: screenWidth / 2, height: containerView.bounds.height)
        let rightFrame = CGRect(x: screenWidth / 2, y: 0, width: screenWidth / 2, height: containerView.bounds.height)
        
        let leftView = UIView(frame: leftFrame)
        let rightView = UIView(frame: rightFrame)
        
        leftView.backgroundColor = .clear
        rightView.backgroundColor = .clear
        
        leftView.addGestureRecognizer(leftTapGesture)
        rightView.addGestureRecognizer(rightTapGesture)
        
        containerView.addSubview(leftView)
        containerView.addSubview(rightView)
    }

    @objc private func handleLeftTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if location.x <= view.frame.size.width / 2 {
            moveToPrevious()
            resetTimer()
        }
    }

    @objc private func handleRightTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if location.x > view.frame.size.width / 2 {
            moveToNext()
            resetTimer()
        }
    }
    
    private func setupSwipeDownGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func handleSwipeDown() {
        dismiss(animated: true, completion: nil)
    }
    
    private func moveToNext() {
        let nextIndex = (currentItemIndex + 1) % items.count
        if nextIndex == 0 {
            dismiss(animated: true, completion: nil)  // Dismiss on the last image
        } else {
            let direction: UIPageViewController.NavigationDirection = .forward
            let nextController = getController(at: nextIndex)
            pageViewController?.setViewControllers([nextController], direction: direction, animated: true)
            currentItemIndex = nextIndex
            startAutoProgression()  // Restart the timer when manually progressing
        }
    }
    
    private func moveToPrevious() {
        let previousIndex = (currentItemIndex - 1 + items.count) % items.count
        let direction: UIPageViewController.NavigationDirection = .reverse
        let previousController = getController(at: previousIndex)
        pageViewController?.setViewControllers([previousController], direction: direction, animated: true)
        currentItemIndex = previousIndex
        startAutoProgression()  // Restart the timer when manually going back
    }
    
    private func updateProgress() {
        for (index, progressView) in progressViews.enumerated() {
            if index < currentItemIndex {
                progressView.setProgress(1.0, animated: false)
            } else if index == currentItemIndex {
                progressView.setProgress(0.0, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIView.animate(withDuration: 10.0, delay: 0, options: .curveLinear, animations: {
                        progressView.setProgress(1.0, animated: true)
                    })
                }
            } else {
                progressView.setProgress(0.0, animated: false)
            }
        }
    }
    
    private func getController(at index: Int) -> UIViewController {
        return items[index].getController()
    }
}

extension CarouselViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentItemIndex == 0 {
            return items.last?.getController()
        }
        return getController(at: currentItemIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentItemIndex + 1 == items.count {
            return items.first?.getController()
        }
        return getController(at: currentItemIndex + 1)
    }
}

extension CarouselViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = items.firstIndex(where: { $0.getController() == visibleViewController }) {
            currentItemIndex = index
            updateProgress()  // Update the progress bar after manual swiping
        }
    }
}

extension CarouselViewController: UIGestureRecognizerDelegate {
    // Implement UIGestureRecognizerDelegate methods if needed
}
