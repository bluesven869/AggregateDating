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
        .when('/discover',
          templateUrl: "discover.html"
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
        .when('/matches',
          templateUrl: "matches.html"
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


controllers.controller("AggController", [ '$scope', '$routeParams', '$location', '$facebook', '$http', '$resource','$cookies','$cookieStore', 'Upload', '$timeout'
  ($scope,$routeParams,$location,$facebook,$http,$resource,$cookies,$cookieStore, Upload, $timeout)->
    
    $scope.login_flag = false
    $scope.show_filter_flag = false
    $scope.prev_bagel = null
    #if(not MyAuthInfo.fbToken?)
    #  $location.path('/login')
    vm = this
    $scope.flag_t = true   #tinder_flag
    $scope.flag_o = true   #Okpid_flag 
    $scope.flag_p = true   #POF_flag 
    $scope.flag_b = true   #Bumble_flag 
    $scope.flag_c = true   #CMB_flag
    $scope.flag_f_r = false #Favorite flag
    $scope.flag_r_r = false #Recent flag
    $scope.flag_e_r = false #Expiring flag
    
    $scope.flag_b_r = false
    $scope.flag_l_r = false   
    $scope.flag_a_r = false   
    $scope.selected_bagel_index = 0
    $scope.BagelsList = [
      {
        images:['Images/1.jpg','Images/1_1.jpg','Images/1_2.jpg','Images/1_3.jpg','Images/1_4.jpg'], selected_image:1, 
        name: 'Maria Vanna',      age:21, nearby:12, school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-5',  selected:false
      }, 
      {
        images:['Images/2.jpg','Images/2_1.jpg','Images/2_2.jpg','Images/2_3.jpg'], selected_image:0, 
        name: 'Leslie Lawsonb',   age:26, nearby:31, school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:2,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-5',  selected:false
      }, 
      {
        images:['Images/3.jpg'], selected_image:0, 
        name: 'Dora Thomas3',     age:23, nearby:45, school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:3,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-11',  selected:false
      }, 
      {
        images:['Images/4.jpg','Images/4_1.jpg','Images/4_2.jpg','Images/4_3.jpg','Images/4_4.jpg', 'Images/4_5.jpg','Images/4_6.jpg','Images/4_7.jpg'], selected_image:3, 
        name: 'Karen Olsen',     age:22, nearby:62, school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:2,
        star:1,CAP:'O', expire_days:2,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        images:['Images/5.jpg','Images/5_1.jpg','Images/5_2.jpg','Images/5_3.jpg','Images/5_4.jpg', 'Images/5_5.jpg'], selected_image:0, 
        name: 'Mittie Phillips', age:20, nearby:1,  school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        images:['Images/6.jpg'], selected_image:0, 
        name: 'Dori Moss',       age:25, nearby:2,  school:'Havard Raw School',
        aboutme:'Now that I’ve given you the pep talk',
        action:4,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        images:['Images/1.jpg','Images/1_1.jpg','Images/1_2.jpg','Images/1_3.jpg','Images/1_4.jpg'], selected_image:0, 
        name: 'Maria Vann',      age:21, nearby:7,  school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-3',  selected:false
      }, 
      {
        images:['Images/2.jpg','Images/2_1.jpg','Images/2_2.jpg','Images/2_3.jpg'], selected_image:0, 
        name: 'Leslie Lawson',   age:26, nearby:43, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:3,
        star:1,CAP:'C', expire_days:2,assigned_date:'2017-1-7',  selected:false
      }, 
      {
        images:['Images/3.jpg'], selected_image:0, 
        name: 'Dora Thomas',     age:23, nearby:67, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:0,CAP:'T', expire_days:3,assigned_date:'2017-1-7',  selected:false
      }, 
      {
        images:['Images/4.jpg','Images/4_1.jpg','Images/4_2.jpg','Images/4_3.jpg','Images/4_4.jpg', 'Images/4_5.jpg','Images/4_6.jpg','Images/4_7.jpg'], selected_image:0, 
        name: 'Karen Olsen',     age:22, nearby:28, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:0,CAP:'T', expire_days:2,assigned_date:'2017-1-8',  selected:false
      }, 
      {
        images:['Images/5.jpg','Images/5_1.jpg','Images/5_2.jpg','Images/5_3.jpg','Images/5_4.jpg', 'Images/5_5.jpg'], selected_image:0, 
        name: 'Mittie Phillips', age:20, nearby:64, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:0,CAP:'P', expire_days:3,assigned_date:'2017-1-8',  selected:false
      }, 
      {
        images:['Images/6.jpg'],selected_image:0,  
        name: 'Dori Moss',       age:25, nearby:21, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:1,CAP:'O', expire_days:1,assigned_date:'2017-1-16',  selected:false
      }, 
      {
        images:['Images/1.jpg','Images/1_1.jpg','Images/1_2.jpg','Images/1_3.jpg','Images/1_4.jpg'], selected_image:0, 
        name: 'Maria Vann',      age:21, nearby:53, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:1,CAP:'C', expire_days:3,assigned_date:'2017-1-9',  selected:false
      }, 
      {
        images:['Images/2.jpg','Images/2_1.jpg','Images/2_2.jpg','Images/2_3.jpg'], selected_image:0, 
        name: 'Leslie Lawson',   age:26, nearby:68, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:0,CAP:'T', expire_days:3,assigned_date:'2017-1-12',  selected:false
      }, 
      {
        images:['Images/3.jpg'], selected_image:0, 
        name: 'Dora Thomas',     age:23, nearby:32, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:2,
        star:1,CAP:'T', expire_days:1,assigned_date:'2017-1-9',  selected:false
      }, 
      {
        images:['Images/4.jpg','Images/4_1.jpg','Images/4_2.jpg','Images/4_3.jpg','Images/4_4.jpg', 'Images/4_5.jpg','Images/4_6.jpg','Images/4_7.jpg'], selected_image:0, 
        name: 'Karen Olsen',     age:22, nearby:53, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:2,
        star:1,CAP:'C', expire_days:3,assigned_date:'2017-1-16', selected:false
      }, 
      {
        images:['Images/5.jpg','Images/5_1.jpg','Images/5_2.jpg','Images/5_3.jpg','Images/5_4.jpg', 'Images/5_5.jpg'], selected_image:0, 
        name: 'Mittie Phillips', age:20, nearby:28, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:1,
        star:1,CAP:'T', expire_days:2,assigned_date:'2017-1-10', selected:false
      }, 
      {
        images:['Images/6.jpg'], selected_image:0, 
        name: 'Dori Moss',       age:25, nearby:92, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:0,CAP:'T', expire_days:3,assigned_date:'2017-1-3', selected:false
      }, 
      {
        images:['Images/1.jpg','Images/1_1.jpg','Images/1_2.jpg','Images/1_3.jpg','Images/1_4.jpg'], selected_image:0, 
        name: 'Maria Vann',      age:21, nearby:22, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:1,CAP:'T', expire_days:1,assigned_date:'2017-1-11', selected:false
      }, 
      {
        images:['Images/2.jpg','Images/2_1.jpg','Images/2_2.jpg','Images/2_3.jpg'], selected_image:0, 
        name: 'Leslie Lawson',   age:26, nearby:122,school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:1,CAP:'B', expire_days:3,assigned_date:'2017-1-9', selected:false
      }, 
      {
        images:['Images/3.jpg'], selected_image:0, 
        name: 'Dora Thomas',     age:23, nearby:32, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-11', selected:false
      }, 
      {
        images:['Images/4.jpg','Images/4_1.jpg','Images/4_2.jpg','Images/4_3.jpg','Images/4_4.jpg', 'Images/4_5.jpg','Images/4_6.jpg','Images/4_7.jpg'], selected_image:0, 
        name: 'Karen Olsen',     age:22, nearby:52, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:0,CAP:'C', expire_days:3,assigned_date:'2017-1-6', selected:false
      }, 
      {
        images:['Images/5.jpg','Images/5_1.jpg','Images/5_2.jpg','Images/5_3.jpg','Images/5_4.jpg', 'Images/5_5.jpg'], selected_image:0, 
        name: 'Mittie Phillips', age:20, nearby:72, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:1,CAP:'T', expire_days:2,assigned_date:'2017-1-12', selected:false
      }, 
      {
        images:['Images/6.jpg'], selected_image:0, 
        name: 'Dori Moss',       age:25, nearby:82, school:'Havard Raw School',aboutme:'Now that I’ve given you the pep talk',
        action:0,
        star:0,CAP:'C', expire_days:3,assigned_date:'2017-1-12', selected:false
      }      
    ]
    #Action type 4 stands for “Woo Like”
    #Action type 3 stands for “Supler Like”
    #Action type 1 stands for “Like”
    #Action type 2 stands for “Pass”
    #Action type 0 stands for “Unviewed” (See CMB app workflow below for details!)

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
      $scope.flag_t   = $scope.convert_to_bool($cookieStore.get('flag_t'),   true)
      $scope.flag_o   = $scope.convert_to_bool($cookieStore.get('flag_o'),   true)
      $scope.flag_p   = $scope.convert_to_bool($cookieStore.get('flag_p'),   true)
      $scope.flag_b   = $scope.convert_to_bool($cookieStore.get('flag_b'),   true)
      $scope.flag_c   = $scope.convert_to_bool($cookieStore.get('flag_c'),   true)
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
      if(f == 1 )   # Matches Page click event
        if(i == 0)          
          $scope.flag_f_r = false
          $scope.flag_r_r = true
          $scope.flag_e_r = false 
        if(i == 1)          
          $scope.flag_f_r = false
          $scope.flag_r_r = false
          $scope.flag_e_r = true    
        if(i == 2)                    
          $scope.flag_f_r = true
          $scope.flag_r_r = false
          $scope.flag_e_r = false
      if(f == 2) # Discover Page click event
        if(i == 0)
          $scope.flag_b_r = true     
          $scope.flag_l_r = false     
          $scope.flag_a_r = false
        if(i == 1)
          $scope.flag_b_r = false     
          $scope.flag_l_r = true     
          $scope.flag_a_r = false
        if(i == 2)
          $scope.flag_b_r = false     
          $scope.flag_l_r = false     
          $scope.flag_a_r = true

      $cookieStore.put('flag_t', $scope.flag_t)
      $cookieStore.put('flag_o', $scope.flag_o)
      $cookieStore.put('flag_p', $scope.flag_p)
      $cookieStore.put('flag_b', $scope.flag_b)
      $cookieStore.put('flag_c', $scope.flag_c)
      
      $cookieStore.put('flag_f_r', $scope.flag_f_r)
      $cookieStore.put('flag_r_r', $scope.flag_r_r)
      $cookieStore.put('flag_e_r', $scope.flag_e_r)

      $cookieStore.put('flag_b_r', $scope.flag_b_r)
      $cookieStore.put('flag_l_r', $scope.flag_l_r)
      $cookieStore.put('flag_a_r', $scope.flag_a_r)
      $timeout ->
        
        $scope.rebuildCarousel()
      , 100;
    # favorite filter in Matches Page  
    $scope.filterBagelonMatchPage = (bagel) ->  
      if(bagel.action != 1 || bagel.action!=3 || bagel.action != 4)
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
    $scope.SortMatches = (bagel) ->
      
      if($scope.flag_f_r)
        return 1-bagel.star
      if($scope.flag_r_r)
        return bagel.expire_days
      if($scope.flag_e_r)
        return Date.parse(bagel.assigned_date)
    # bagels filter in Discover Page
    $scope.filterBagelonDiscoverPage = (bagel) -> 
         
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

    $scope.getNetworkTitle = (net) ->
      if(net == "T") 
        return "Tinder"  
      if(net == "O") 
        return "OKCupid"  
      if(net == "P") 
        return "POF"  
      if(net == "B") 
        return "Bumble"  
      if(net == "C") 
        return "CMB"  
    $scope.onStar = (bagel) ->
      bagel.selected_star = !bagel.star
      bagel.anim_start = true
      $timeout ->
          bagel.star = bagel.selected_star
          bagel.anim_start = false
        , 1000;
      
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
    
    $scope.rebuildCarousel = ->         
      console.log "rebuildCarousel"   
      jQuery('.sky-carousel').carousel
        itemWidth: 260
        itemHeight: 260
        distance: 12
        selectedItemDistance: 75
        enableMouseWheel: 0
        loop: 0
        selectedItemZoomFactor: 1
        unselectedItemZoomFactor: 0.5
        unselectedItemAlpha: 0.6
        motionStartDistance: 210
        topMargin: 0
        gradientStartPoint: 0.35
        gradientOverlayColor: '#e6e6e6'
        gradientOverlaySize: 190
        selectByClick: false
      console.log "rebuildCarouselEnd"   
  ])
