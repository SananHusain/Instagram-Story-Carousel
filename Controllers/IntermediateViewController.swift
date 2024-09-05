//
//  IntermediateViewController.swift
//  Vought Showcase
//
//  Created by Apple on 9/5/24.
//


import UIKit

final class IntermediateViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSwipeDownGesture()
    }

    // Function to open CarouselViewController with a bottom-up animation
    @IBAction private func openCarouselViewController() {
        let carouselItems: [CarouselItem] = [
                    HomeLanderCarouselItem(),
                    MaeveCarouselItem(),
                    BlackNoirCarouselItem(),
                    ATrainCarouselItem()
                ]
        let carouselVC = CarouselViewController(items: carouselItems)
        carouselVC.modalPresentationStyle = .fullScreen
        carouselVC.modalTransitionStyle = .coverVertical
        
        present(carouselVC, animated: true, completion: nil)
    }

    // Function to configure swipe down gesture for dismissing the view controller
    private func configureSwipeDownGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    // Handler for swipe down gesture
    @objc private func handleSwipeDown() {
        dismiss(animated: true, completion: nil)
    }
}
