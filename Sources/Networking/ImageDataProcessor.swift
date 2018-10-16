//
//  ImageDataProcessor.swift
//  Kingfisher
//
//  Created by Wei Wang on 2018/10/11.
//
//  Copyright (c) 2018年 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

class ImageDataProcessor {
    let data: Data
    let callbacks: [SessionDataTask.TaskCallback]

    let onImageProcessed = Delegate<(Result<Image>, SessionDataTask.TaskCallback), Void>()

    init(data: Data, callbacks: [SessionDataTask.TaskCallback]) {
        self.data = data
        self.callbacks = callbacks
    }

    func process() {

        var processedImages = [String: Image]()

        for callback in callbacks {
            let processor = callback.options.processor
            var image = processedImages[processor.identifier]
            if image == nil {
                image = processor.process(item: .data(data), options: callback.options)
                processedImages[processor.identifier] = image
            }

            if let image = image {
                let imageModifier = callback.options.imageModifier
                var finalImage = imageModifier.modify(image)
                if callback.options.backgroundDecode {
                    finalImage = finalImage.kf.decoded
                }
                onImageProcessed.call((.success(finalImage), callback))
            } else {
                let error = KingfisherError2.processorError(
                    reason: .processingFailed(processor: processor, item: .data(data)))
                onImageProcessed.call((.failure(error), callback))
            }
        }


    }
}
