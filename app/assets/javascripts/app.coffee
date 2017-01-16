aggregate_dating = angular.module('aggregate_dating',[
  	'templates',
  	'ngRoute',
    'ngResource',
  	'controllers',
  	'facebook',
    'ngFileUpload',
    'ngCookies'
])
MyAuthInfo = []
aggregate_dating.config([ '$routeProvider',
  	($routeProvider)->
    	$routeProvider
        .when('/main',
          templateUrl: "main.html"
          controller: 'AggController'
        )
        .when('/login',
          templateUrl: "login.html"
          controller: 'LoginController'
        )
        .when('/list',
          templateUrl: "list.html"
          controller: 'AggController'
        )
        .when('/bagels',
          templateUrl: "bagel-list.html"
          controller: 'AggController'
        )        
        .when('/account',
          templateUrl: "account.html"
          controller: 'AggController'
        )
])

aggregate_dating.config([ '$facebookProvider',
 	($facebookProvider)->
      	$facebookProvider
        .init({
            appId: '1609654029341787'
        })
])

aggregate_dating.config(['$qProvider', 
  ($qProvider)->
    $qProvider.errorOnUnhandledRejections(false);
])


controllers = angular.module('controllers',[])

controllers.controller("LoginController", [ '$scope', '$routeParams', '$location', '$facebook', '$http', '$resource', '$timeout'
  ($scope,$routeParams,$location,$facebook,$http, $resource, $timeout)->
    $scope.fb_login_flag = false 
    $scope.loginFacebook = ->
      $scope.fb_login_flag = true
      $facebook.login(scope: 'email').then ((response) ->        
        MyAuthInfo.fbToken = response.authResponse.accessToken
        MyAuthInfo.fbUserID = response.authResponse.userID
        $scope.fbToken = response.authResponse.accessToken
        $scope.fbUserID = response.authResponse.userID 
        $facebook.api('/me').then((response) ->
            MyAuthInfo.fbName = response.name;
            MyAuthInfo.fbPhoto = "http://graph.facebook.com/"+response.id+"/picture"
            console.log MyAuthInfo.fbPhoto
            $scope.fb_login_flag = false
            $scope.loginTinder()
        )       
        
    ), (response) ->
        console.log 'FB Login Error', response

    $scope.loginTinder = ->
      $scope.tinderInfo = [] 
      $scope.tinder_login_flag = true
      Tinder = $resource('/tinder', { format: 'json' })
      Tinder.query(fbToken: $scope.fbToken, fbUserID: $scope.fbUserID , (results) -> 
        $scope.tinderInfo = results        
        if( results[0].Result == "success" )        
          console.log "Tinder Login Success"
          $("#tinder .Checked").show();
          $("#tinder .UnChecked").hide();
        else
          console.log "Tinder Login Failed"
          $("#tinder .UnChecked").show();
          $("#tinder .Checked").hide();
        $scope.tinder_login_flag = false
        $scope.loginCMB()
      )
    $scope.loginCMB = ->
      #login with CMB
      #CURL commands:
      # 1. curl https://api.coffeemeetsbagel.com/profile/me -H "App-version: 779" -H
      $scope.cmb_login_flag = true
      MyAuthInfo.cmbInfo = [] 
      Cmb = $resource('/cmb', { format: 'json' })
      Cmb.query(fbToken: MyAuthInfo.fbToken , (results) ->         
        console.log results[0]
        if( results[0].loginResult == "success" )        
          console.log "CMB Login Success"
          MyAuthInfo.cmbInfo.profile_id = results[0].jsonObj.profile_id
          MyAuthInfo.cmbInfo.sessionid = results[0].sessionid        
          $("#cmb .Checked").show();
          $("#cmb .UnChecked").hide();
        else
          console.log "CMB Login Failed"
          $("#cmb .UnChecked").show();
          $("#cmb .Checked").hide();
        $scope.cmb_login_flag = false
        $scope.loginBumble()        
      )
    $scope.loginBumble = ->
      #login with CMB
      #CURL commands:
      # 1. curl https://api.coffeemeetsbagel.com/profile/me -H "App-version: 779" -H
      $scope.bumble_login_flag = true
      MyAuthInfo.bumbleInfo = [] 
      Bumble = $resource('/bumble', { format: 'json' })
      Bumble.query(fbToken: MyAuthInfo.fbToken , (results) ->         
        if( results[0].loginResult == "success" )        
          console.log "Bumble Login Success"
          MyAuthInfo.bumbleInfo.profile_id = results[0].jsonObj.profile_id
          MyAuthInfo.bumbleInfo.sessionid = results[0].sessionid        
          $("#bumble .Checked").show();
          $("#bumble .UnChecked").hide();          
        else
          console.log "Bumble Login Failed"
          $("#bumble .UnChecked").show();
          $("#bumble .Checked").hide();
        $scope.bumble_login_flag = false                
        $timeout ->
          $location.path('/main');
        , 2000;
        
      )
])


controllers.controller("AggController", [ '$scope', '$routeParams', '$location', '$facebook', '$http', '$resource','$cookies', 'Upload'
  ($scope,$routeParams,$location,$facebook,$http,$resource,$cookies, Upload)->
    
    $scope.login_flag = false
    $scope.show_filter_flag = false
    $scope.prev_bagel = null
    #if(not MyAuthInfo.fbToken?)
    #  $location.path('/login')
    favoriteCookie = $cookies.get('myFavorite');
    # Setting a cookie
    console.log favoriteCookie
    $cookies.put('myFavorite', 'oatmeal');
    $scope.flag_t = true   #tinder_flag
    $scope.flag_o = true   #Okpid_flag 
    $scope.flag_p = true   #POF_flag 
    $scope.flag_b = true   #Bumble_flag 
    $scope.flag_c = true   #CMB_flag
    $scope.flag_f_r = false #Favorite flag
    $scope.flag_r_r = false #Recent flag
    $scope.flag_e_r = false #Expiring flag
    
    $scope.flag_1_r = false
    $scope.flag_2_r = false
    $scope.flag_5_r = false
    $scope.flag_b_r = false
    $scope.flag_l_r = false   
    $scope.flag_a_r = false   

    $scope.BagelsList = [
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':3,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':1,'matches':0,'recent':1, 'selected':false}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':3,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'O', 'expire_days':2,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':3,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'P', 'expire_days':1,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':3,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'B', 'expire_days':2,'matches':0,'recent':1, 'selected':false}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':3,'matches':0,'recent':1, 'selected':false}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':2,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'P', 'expire_days':3,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'O', 'expire_days':1,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'C', 'expire_days':3,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':3,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':1,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'C', 'expire_days':3,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':2,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':3,'matches':0,'recent':0, 'selected':false}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':1,'matches':0,'recent':1, 'selected':false}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'B', 'expire_days':3,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':1,'matches':0,'recent':1, 'selected':false}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'C', 'expire_days':3,'matches':1,'recent':0, 'selected':false}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':1,'CAP':'T', 'expire_days':2,'matches':1,'recent':1, 'selected':false}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','star':0,'CAP':'T', 'expire_days':3,'matches':0,'recent':0, 'selected':false}      
    ]

    $scope.networks = [
      {'name': 'Tinder', 'CAP':'T'},
      {'name': 'OKCupid', 'CAP':'O'},
      {'name': 'POF', 'CAP':'P'},
      {'name': 'Bumble', 'CAP':'B'},
      {'name': 'CMB', 'CAP':'C'}
    ]
    $scope.selected_networks = []

    # top matches fileter in Bagels Page  
    $scope.filterBagel1 = (bagel) ->  
      if(bagel.matches == 1)      
        if($scope.flag_f_r)
          if(bagel.star == 0)
            return false
        if($scope.flag_r_r)
          if(bagel.recent == 0)
            return false
        if(!$scope.flag_e_r)
          if(bagel.expire_days == 0)
            return false  
        if($scope.flag_t)
          if(bagel.CAP == "T")
              return bagel            
        if($scope.flag_o)
          if(bagel.CAP == "O")
            return bagel
        if($scope.flag_p)
          if(bagel.CAP == "P")
            return bagel
        if($scope.flag_b)
          if(bagel.CAP == "B")
            return bagel
        if($scope.flag_c)
          if(bagel.CAP == "C")
            return bagel
        return false
    # matches fileter in Bagels Page  
    $scope.filterBagel0 = (bagel) ->
      if(bagel.matches == 0)        
        if($scope.flag_f_r)
          if(bagel.star == 0)
            return false
        if($scope.flag_r_r)
          if(bagel.recent == 0)
            return false
        if(!$scope.flag_e_r)
          if(bagel.expire_days == 0)
            return false  
        if($scope.flag_t)
          if(bagel.CAP == "T")
              return bagel            
        if($scope.flag_o)
          if(bagel.CAP == "O")
            return bagel
        if($scope.flag_p)
          if(bagel.CAP == "P")
            return bagel
        if($scope.flag_b)
          if(bagel.CAP == "B")
            return bagel
        if($scope.flag_c)
          if(bagel.CAP == "C")
            return bagel
        return false
    # matches fileter in Main Page  
    $scope.filterBagel2 = (bagel) ->
      if($scope.flag_f_r)
        if(bagel.star == 0)
          return false
      if($scope.flag_r_r)
        if(bagel.recent == 0)
          return false
      if(!$scope.flag_e_r)
        if(bagel.expire_days == 0)
          return false  
      if($scope.flag_t)
        if(bagel.CAP == "T")
            return bagel            
      if($scope.flag_o)
        if(bagel.CAP == "O")
          return bagel
      if($scope.flag_p)
        if(bagel.CAP == "P")
          return bagel
      if($scope.flag_b)
        if(bagel.CAP == "B")
          return bagel
      if($scope.flag_c)
        if(bagel.CAP == "C")
          return bagel
      return false

    $scope.onNetwork = (net, chk) ->
      value = document.getElementById(""+chk+"-check").checked;
      switch chk
        when "T" then $scope.flag_t = value
        when "O" then $scope.flag_o = value
        when "P" then $scope.flag_p = value
        when "B" then $scope.flag_b = value
        when "C" then $scope.flag_c = value
    $scope.onSort = (sort) ->
      value = document.getElementById(""+sort+"-S-check").checked;
      switch sort
        when "F" then $scope.flag_f_r = value
        when "R" then $scope.flag_r_r = value
        when "E" then $scope.flag_e_r = value   
        when "1" then $scope.flag_1_r = value   
        when "2" then $scope.flag_2_r = value   
        when "5" then $scope.flag_5_r = value   
        when "B" then $scope.flag_b_r = value   
        when "L" then $scope.flag_l_r = value   
        when "A" then $scope.flag_a_r = value   
        
    $scope.onNetworkF = (cate) ->
      switch cate
        when "T" then $scope.flag_t = !$scope.flag_t
        when "O" then $scope.flag_o = !$scope.flag_o
        when "P" then $scope.flag_p = !$scope.flag_p
        when "B" then $scope.flag_b = !$scope.flag_b
        when "C" then $scope.flag_c = !$scope.flag_c     
        when "FR" then $scope.flag_f_r = !$scope.flag_f_r     
        when "RR" then $scope.flag_r_r = !$scope.flag_r_r     
        when "ER" then $scope.flag_e_r = !$scope.flag_e_r     
        when "1R" then $scope.flag_1_r = !$scope.flag_1_r      
        when "2R" then $scope.flag_2_r = !$scope.flag_2_r      
        when "5R" then $scope.flag_5_r = !$scope.flag_5_r    
        when "BR" then $scope.flag_b_r = !$scope.flag_b_r     
        when "LR" then $scope.flag_l_r = !$scope.flag_l_r      
        when "AR" then $scope.flag_a_r = !$scope.flag_a_r        
      #if(value== "true"?)
      #  $scope.selected_networks.push net
      #else
      #  ind = $scope.selected_networks.indexOf(net)
      #  $scope.selected_networks.splice(ind,1)

    $scope.onFilterDlg = ->
      $scope.show_filter_flag = not $scope.show_filter_flag       

    # Click Event in List page
    $scope.clickBagel = (bagel) ->
      if($scope.prev_bagel?)
        $scope.prev_bagel.selected = false
      bagel.selected = true
      $scope.show_filter_flag = false
      $scope.prev_bagel = bagel      
      $scope.my_profile = bagel.aboutme

    $scope.refreshCarousel = ->
      $('.sky-carousel').carousel
        itemWidth: 485
        itemHeight: 485
        distance: 0
        selectedItemDistance: 0
        enableMouseWheel: 0
        loop: 0
        selectedItemZoomFactor: 1
        unselectedItemZoomFactor: 0.85
        unselectedItemAlpha: 0.6
        motionStartDistance: 210
        topMargin: 85
        gradientStartPoint: 0.35
        gradientOverlayColor: '#e6e6e6'
        gradientOverlaySize: 190
        selectByClick: true      
  ])
  .directive 'on-finish-render', ->
  {
    restrict: 'A'
    link: (scope, element, attr) ->
      if scope.$last == true
        element.ready ->
          #console.log 'calling:' + attr.onFinishRender
          # CALL TEST HERE!
          scope.refreshCarousel
          return
      return

  }
