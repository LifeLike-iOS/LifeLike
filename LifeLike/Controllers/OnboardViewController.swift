//
//  OnboardViewController.swift
//  LifeLike
//
//  Created by Devin Fan on 12/4/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import UIKit

class OnboardViewController: UIPageViewController {

    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "Page1"),
            self.getViewController(withIdentifier: "Page2"),
            self.getViewController(withIdentifier: "Page3")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = pages.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        navigationController?.isNavigationBarHidden = true
    }
}

extension OnboardViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex + 1
        guard previousIndex < pages.count else {
            navigationController?.popViewController(animated: false)
            dismiss(animated: false, completion: nil)
            return nil
        }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
}

private extension OnboardViewController {
    func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: identifier)
    }
}
