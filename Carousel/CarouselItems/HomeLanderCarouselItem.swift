//
//  HomeLanderCarouselItem.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import UIKit


final class HomeLanderCarouselItem: CarouselItem {
    private var viewController: ImageViewController?
      
      // Get controller
      func getController() -> UIViewController {
          if viewController == nil {
              let imageViewController = ImageViewController(imageName: "butcher")
              
              // Setup the callbacks for next and previous
              imageViewController.onNext = { [weak self] in
                  self?.moveToNext()
              }
              
              imageViewController.onPrevious = { [weak self] in
                  self?.moveToPrevious()
              }
              
              viewController = imageViewController
          }
          return viewController!
      }
      
      private func moveToNext() {
          // Implement the logic to move to the next image
      }
      
      private func moveToPrevious() {
          // Implement the logic to move to the previous image
      }
  }