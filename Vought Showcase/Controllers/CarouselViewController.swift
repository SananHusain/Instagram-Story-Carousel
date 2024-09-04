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
    
    /// Array of progress views, one for each image
    private var progressViews: [UIProgressView] = []
    
    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    
    /// Carousel items
    private var items: [CarouselItem] = []
        
        /// Current item index
        private var currentItemIndex: Int = 0 {
            didSet {
                // Update progress view based on current item index
                updateProgressViews(for: currentItemIndex)
            }
        }

        /// Initializer
        /// - Parameter items: Carousel items
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
       }
    
        
        /// Initialize page view controller
        private func initPageViewController() {
            // Create pageViewController
            pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            
            // Set up pageViewController
            pageViewController?.dataSource = self
            pageViewController?.delegate = self
            pageViewController?.setViewControllers([getController(at: currentItemIndex)], direction: .forward, animated: true)
            
            guard let theController = pageViewController else {
                return
            }
            
            // Add pageViewController in container view
            add(asChildViewController: theController, containerView: containerView)
        }
    
    /// Set up progress stack view with individual progress bars
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

        // Function to start automatic progression
        private func startAutoProgression() {
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                let nextIndex = (self.currentItemIndex + 1) % self.items.count
                let direction: UIPageViewController.NavigationDirection = nextIndex > self.currentItemIndex ? .forward : .reverse
                
                let nextController = self.getController(at: nextIndex)
                self.pageViewController?.setViewControllers([nextController], direction: direction, animated: true, completion: nil)
                
                self.currentItemIndex = nextIndex
            }
        }
    
    private func moveToNext() {
        let nextIndex = (currentItemIndex + 1) % items.count
        let direction: UIPageViewController.NavigationDirection = .forward
        let nextController = getController(at: nextIndex)
        pageViewController?.setViewControllers([nextController], direction: direction, animated: true)
        currentItemIndex = nextIndex
        updateProgress()
    }

    private func moveToPrevious() {
        let previousIndex = (currentItemIndex - 1 + items.count) % items.count
        let direction: UIPageViewController.NavigationDirection = .reverse
        let previousController = getController(at: previousIndex)
        pageViewController?.setViewControllers([previousController], direction: direction, animated: true)
        currentItemIndex = previousIndex
        updateProgress()
    }
    
    private func updateProgress() {
        let progress = Float(currentItemIndex + 1) / Float(items.count)
        for (index, progressView) in progressViews.enumerated() {
            progressView.setProgress(index < currentItemIndex ? 1 : 0, animated: true)
        }
    }



    /// Update the progress views based on the current item index
       private func updateProgressViews(for index: Int) {
           for i in 0..<progressViews.count {
               progressViews[i].setProgress(i <= index ? 1.0 : 0.0, animated: true)
           }
       }

       private func getController(at index: Int) -> UIViewController {
           return items[index].getController()
       }
    // Setup tap gesture recognizers for left and right tap detection
    private func setupTapGestures() {
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))
        
        let leftView = UIView()
        let rightView = UIView()
        
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leftView)
        view.addSubview(rightView)
        
        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftView.topAnchor.constraint(equalTo: view.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightView.topAnchor.constraint(equalTo: view.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
        
        leftView.addGestureRecognizer(leftTap)
        rightView.addGestureRecognizer(rightTap)
    }
    
    @objc private func handleLeftTap() {
        moveToPrevious()
    }
    
    @objc private func handleRightTap() {
        moveToNext()
    }
}


    // MARK: UIPageViewControllerDataSource methods
    extension CarouselViewController: UIPageViewControllerDataSource {
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            if currentItemIndex == 0 {
                return items.last?.getController()
            }
            return getController(at: currentItemIndex - 1)
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            if currentItemIndex + 1 == items.count {
                return items.first?.getController()
            }
            return getController(at: currentItemIndex + 1)
        }
    }

    // MARK: UIPageViewControllerDelegate methods
    extension CarouselViewController: UIPageViewControllerDelegate {
        
        public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = items.firstIndex(where: { $0.getController() == visibleViewController }) {
                currentItemIndex = index
            }
        }
    }

