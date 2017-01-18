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


controllers.controller("AggController", [ '$scope', '$routeParams', '$location', '$facebook', '$http', '$resource','$cookies','$cookieStore', 'Upload'
  ($scope,$routeParams,$location,$facebook,$http,$resource,$cookies,$cookieStore, Upload)->
    
    $scope.login_flag = false
    $scope.show_filter_flag = false
    $scope.prev_bagel = null
    #if(not MyAuthInfo.fbToken?)
    #  $location.path('/login')
    
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
      {image:'Images/1.jpg', name: 'Maria Vann',      age:21, nearby:12, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:3,favorite:0,assigned_date:'2017-1-5',  selected:false}, 
      {image:'Images/2.jpg', name: 'Leslie Lawson',   age:26, nearby:31, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:1,favorite:0,assigned_date:'2017-1-5',  selected:false}, 
      {image:'Images/3.jpg', name: 'Dora Thomas',     age:23, nearby:45, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:3,favorite:1,assigned_date:'2017-1-5',  selected:false}, 
      {image:'Images/4.jpg', name: 'Karen Olsen',     age:22, nearby:62, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'O', expire_days:2,favorite:1,assigned_date:'2017-1-6',  selected:false}, 
      {image:'Images/5.jpg', name: 'Mittie Phillips', age:20, nearby:1,  school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:3,favorite:1,assigned_date:'2017-1-6',  selected:false}, 
      {image:'Images/6.jpg', name: 'Dori Moss',       age:25, nearby:2,  school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'P', expire_days:1,favorite:0,assigned_date:'2017-1-6',  selected:false}, 
      {image:'Images/1.jpg', name: 'Maria Vann',      age:21, nearby:7,  school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:3,favorite:1,assigned_date:'2017-1-7',  selected:false}, 
      {image:'Images/2.jpg', name: 'Leslie Lawson',   age:26, nearby:43, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'B', expire_days:2,favorite:0,assigned_date:'2017-1-7',  selected:false}, 
      {image:'Images/3.jpg', name: 'Dora Thomas',     age:23, nearby:67, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:3,favorite:0,assigned_date:'2017-1-7',  selected:false}, 
      {image:'Images/4.jpg', name: 'Karen Olsen',     age:22, nearby:28, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:2,favorite:0,assigned_date:'2017-1-8',  selected:false}, 
      {image:'Images/5.jpg', name: 'Mittie Phillips', age:20, nearby:64, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'P', expire_days:3,favorite:1,assigned_date:'2017-1-8',  selected:false}, 
      {image:'Images/6.jpg', name: 'Dori Moss',       age:25, nearby:21, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'O', expire_days:1,favorite:1,assigned_date:'2017-1-8',  selected:false}, 
      {image:'Images/1.jpg', name: 'Maria Vann',      age:21, nearby:53, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'C', expire_days:3,favorite:0,assigned_date:'2017-1-9',  selected:false}, 
      {image:'Images/2.jpg', name: 'Leslie Lawson',   age:26, nearby:68, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:3,favorite:1,assigned_date:'2017-1-9',  selected:false}, 
      {image:'Images/3.jpg', name: 'Dora Thomas',     age:23, nearby:32, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:1,favorite:1,assigned_date:'2017-1-9',  selected:false}, 
      {image:'Images/4.jpg', name: 'Karen Olsen',     age:22, nearby:53, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'C', expire_days:3,favorite:1,assigned_date:'2017-1-10', selected:false}, 
      {image:'Images/5.jpg', name: 'Mittie Phillips', age:20, nearby:28, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:2,favorite:0,assigned_date:'2017-1-10', selected:false}, 
      {image:'Images/6.jpg', name: 'Dori Moss',       age:25, nearby:92, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:3,favorite:0,assigned_date:'2017-1-10', selected:false}, 
      {image:'Images/1.jpg', name: 'Maria Vann',      age:21, nearby:22, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:1,favorite:0,assigned_date:'2017-1-11', selected:false}, 
      {image:'Images/2.jpg', name: 'Leslie Lawson',   age:26, nearby:122,school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'B', expire_days:3,favorite:1,assigned_date:'2017-1-11', selected:false}, 
      {image:'Images/3.jpg', name: 'Dora Thomas',     age:23, nearby:32, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:1,favorite:0,assigned_date:'2017-1-11', selected:false}, 
      {image:'Images/4.jpg', name: 'Karen Olsen',     age:22, nearby:52, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'C', expire_days:3,favorite:1,assigned_date:'2017-1-12', selected:false}, 
      {image:'Images/5.jpg', name: 'Mittie Phillips', age:20, nearby:72, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:1,CAP:'T', expire_days:2,favorite:1,assigned_date:'2017-1-12', selected:false}, 
      {image:'Images/6.jpg', name: 'Dori Moss',       age:25, nearby:82, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',star:0,CAP:'T', expire_days:3,favorite:0,assigned_date:'2017-1-12', selected:false}      
    ]

    $scope.networks = [
      {name: 'Tinder', CAP:'T', 'flag':'flag_t'},
      {name: 'OKCupid', CAP:'O', 'flag':'flag_o'},
      {name: 'POF', CAP:'P', 'flag':'flag_p'},
      {name: 'Bumble', CAP:'B', 'flag':'flag_b'},
      {name: 'CMB', CAP:'C', 'flag':'flag_c'}
    ]
    $scope.selected_networks = []

    $scope.convert_to_bool = (flag, f_d) ->
      new_flag = false        
      if (flag == undefined)
        new_flag = f_d
      else 
        new_flag = flag
      return new_flag

    $scope.init = ->      
      $scope.flag_t   = $scope.convert_to_bool($cookieStore.get('flag_t'), true)
      $scope.flag_o   = $scope.convert_to_bool($cookieStore.get('flag_o'), true)
      $scope.flag_p   = $scope.convert_to_bool($cookieStore.get('flag_p'), true)
      $scope.flag_b   = $scope.convert_to_bool($cookieStore.get('flag_b'), true)
      $scope.flag_c   = $scope.convert_to_bool($cookieStore.get('flag_c'), true)      
      $scope.flag_1_r = $scope.convert_to_bool($cookieStore.get('flag_1_r'), true)
      $scope.flag_2_r = $scope.convert_to_bool($cookieStore.get('flag_2_r'), true)
      $scope.flag_5_r = $scope.convert_to_bool($cookieStore.get('flag_5_r'), true)
      
      $scope.flag_f_r = $scope.convert_to_bool($cookieStore.get('flag_f_r'), false)
      $scope.flag_r_r = $scope.convert_to_bool($cookieStore.get('flag_r_r'), true)
      $scope.flag_e_r = $scope.convert_to_bool($cookieStore.get('flag_e_r'), false)
      
      $scope.flag_b_r = $scope.convert_to_bool($cookieStore.get('flag_b_r'), false)
      $scope.flag_l_r = $scope.convert_to_bool($cookieStore.get('flag_l_r'), false)
      $scope.flag_a_r = $scope.convert_to_bool($cookieStore.get('flag_a_r'), false)
      
      today = new Date
      for bagel, i in $scope.BagelsList
        d1 = new Date(bagel.assigned_date)
        diff = today-d1
        bagel.expire_days = Math.floor(diff / (3600 * 24*1000))
      
    $scope.set_cookie_from_flag = (f, i)->  
      if(f == 1)
        if(i == 0)
          if($scope.flag_r_r)     
            $scope.flag_e_r = false
          else
            $scope.flag_r_r = true
          $scope.reserve = true
        if(i == 1)
          if($scope.flag_e_r)     
            $scope.flag_r_r = false
          else
            $scope.flag_e_r = true
          $scope.reserve = false
      $cookieStore.put('flag_t', $scope.flag_t)
      $cookieStore.put('flag_o', $scope.flag_o)
      $cookieStore.put('flag_p', $scope.flag_p)
      $cookieStore.put('flag_b', $scope.flag_b)
      $cookieStore.put('flag_c', $scope.flag_c)
      
      $cookieStore.put('flag_1_r', $scope.flag_1_r)
      $cookieStore.put('flag_2_r', $scope.flag_2_r)
      $cookieStore.put('flag_5_r', $scope.flag_5_r)
      
      $cookieStore.put('flag_f_r', $scope.flag_f_r)
      $cookieStore.put('flag_r_r', $scope.flag_r_r)
      $cookieStore.put('flag_e_r', $scope.flag_e_r)

      $cookieStore.put('flag_b_r', $scope.flag_b_r)
      $cookieStore.put('flag_l_r', $scope.flag_l_r)
      $cookieStore.put('flag_a_r', $scope.flag_a_r)

    # top matches fileter in Bagels Page  
    $scope.filterBagel1 = (bagel) ->  
      if(bagel.favorite == 1)      
        if($scope.flag_f_r)
          if(bagel.favorite == 0)
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
      if(bagel.favorite == 0)        
        if($scope.flag_f_r)
          if(bagel.favorite == 0)
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
