//
//   HttpController.swift
//  ZHEmotionMusic
//
//  Created by 钟桓 on 15/5/26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

import UIKit

/**
*  协议负责处理网络连接后的数据处理
*/
protocol HttpProtocol{
    /**
    负责处理网络连接后的数据处理
    
    :param: results 需要处理的数据
    */
    func didReceiveResults(results : NSDictionary)
    
}

/**
*  负责网络连接
*/
class HttpController: NSObject {
    
    var delegate : HttpProtocol?
    
    /**
        给定url，访问网络资源
    
    :param: url 资源URL地址
    */
    func onSearch(url : String) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let nsUrl = NSURL(string: url)
        let request:NSURLRequest = NSURLRequest(URL : nsUrl!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request){
            (data,response,error) -> Void in
            if error == nil {
                
                var jsonResult : NSDictionary  = NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.MutableContainers, error : nil) as! NSDictionary
                
                
                self.delegate?.didReceiveResults(jsonResult)
                
            }else{
                println(error)
            }
            
            
        }
        
        task.resume()
        
    }
    
    
}
