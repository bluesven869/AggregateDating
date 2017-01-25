aggregate_dating = angular.module('aggregate_dating',[
  	'templates',
  	'ngRoute',
    'ngResource',
  	'controllers',
  	'facebook',
    'ngFileUpload',
    'ngCookies',
    'angular-carousel',
    'luegg.directives'
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
        .when('/messages',
          templateUrl: "messages.html"
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
    $scope.prev_bagel = null;
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
    $scope.flag_woo_like = false
    $scope.flag_super_like= false
    $scope.search_name = ""

    $scope.BagelsList = [
      {
        bagel_id:"T0000001",
        images:['Images/1.jpg','Images/1_1.jpg','Images/1_2.jpg','Images/1_3.jpg','Images/1_4.jpg'], selected_image:1, 
        name: 'Kylee Alger',      age:21, nearby:12, school:'Havard Raw School',
        aboutme:'This is the Kylee Alger\'s Profile.',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-5',  selected:false
      }, 
      {
        bagel_id:"T0000002",
        images:['Images/2.jpg','Images/2_1.jpg','Images/2_2.jpg','Images/2_3.jpg'], selected_image:0, 
        name: 'Jaylah Berg',   age:26, nearby:31, school:'Havard Raw School',
        aboutme:'This is the Jaylah Berg\'s Profile.',
        action:2,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-5',  selected:false
      }, 
      {
        bagel_id:"T0000003",
        images:['Images/3.jpg'], selected_image:0, 
        name: 'Hayden Chavis',     age:23, nearby:45, school:'Havard Raw School',
        aboutme:'This is the Hayden Chavis\'s Profile.',
        action:3,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-11',  selected:false
      }, 
      {
        bagel_id:"O0000004",
        images:['Images/4.jpg','Images/4_1.jpg','Images/4_2.jpg','Images/4_3.jpg','Images/4_4.jpg', 'Images/4_5.jpg','Images/4_6.jpg','Images/4_7.jpg'], selected_image:3, 
        name: 'Tara Derr',     age:22, nearby:62, school:'Havard Raw School',
        aboutme:'This is the Tara Derr\'s Profile.',
        action:2,
        star:1,CAP:'O', expire_days:2,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        bagel_id:"T0000005",
        images:['Images/5.jpg','Images/5_1.jpg','Images/5_2.jpg','Images/5_3.jpg','Images/5_4.jpg', 'Images/5_5.jpg'], selected_image:0, 
        name: 'Annie Eller', age:20, nearby:1,  school:'Havard Raw School',
        aboutme:'This is the Annie Eller\'s Profile.',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        bagel_id:"T0000006",
        images:['Images/6.jpg'], selected_image:0, 
        name: 'Lillianna Fiore',       age:25, nearby:2,  school:'Havard Raw School',
        aboutme:'This is the Lillianna Fiore\'s Profile.',
        action:4,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-6',  selected:false
      }, 
      {
        bagel_id:"T0000007",
        images:['Images/7.jpg'], selected_image:0, 
        name: 'Selina Giles',      age:21, nearby:7,  school:'Havard Raw School',
        aboutme:'This is the Selina Giles\'s Profile.',
        action:1,
        star:1,CAP:'T', expire_days:3,assigned_date:'2017-1-3',  selected:false
      }, 
      {
        bagel_id:"C0000008",
        images:['Images/8.jpg'], selected_image:0, 
        name: 'Bella Hays',   age:26, nearby:43, school:'Havard Raw School',
        aboutme:'This is the Bella Hays\'s Profile.',
        action:3,
        star:1,CAP:'C', expire_days:2,assigned_date:'2017-1-7',  selected:false
      }, 
      {
        bagel_id:"T0000009",
        images:['Images/9.jpg'], selected_image:0, 
        name: 'Selah Isaac',     age:23, nearby:67, school:'Havard Raw School',
        aboutme:'This is the Selah Isaac\'s Profile.',
        action:1,
        star:0,CAP:'T', expire_days:3,assigned_date:'2017-1-7',  selected:false
      }, 
      {
        bagel_id:"B0000010",
        images:['Images/10.jpg'], selected_image:0, 
        name: 'Matilda Jacob',     age:22, nearby:28, school:'Havard Raw School',\
        aboutme:'This is the Matilda Jacob\'s Profile.',
        action:1,
        star:0,CAP:'B', expire_days:2,assigned_date:'2017-1-8',  selected:false
      }, 
      {
        bagel_id:"P0000011",
        images:['Images/11.jpg'], selected_image:0, 
        name: 'Kiersten Kenney', age:20, nearby:64, school:'Havard Raw School',
        aboutme:'This is the Kiersten Kenney\'s Profile.',
        action:1,
        star:0,CAP:'P', expire_days:3,assigned_date:'2017-1-8',  selected:false
      }, 
      {
        bagel_id:"O0000012",
        images:['Images/12.jpg'], selected_image:0, 
        name: 'Alison Loftis',       age:25, nearby:21, school:'Havard Raw School',
        aboutme:'This is the Alison Loftis\'s Profile.',
        action:1,
        star:1,CAP:'O', expire_days:1,assigned_date:'2017-1-16',  selected:false
      }, 
      {
        bagel_id:"C0000013",
        images:['Images/13.jpg'], selected_image:0, 
        name: 'Frida Mccauley',      age:21, nearby:53, school:'Havard Raw School',
        aboutme:'This is the Frida Mccauley\'s Profile.',
        action:1,
        star:1,CAP:'C', expire_days:3,assigned_date:'2017-1-9',  selected:false
      }, 
      {
        bagel_id:"B0000014",
        images:['Images/14.jpg'], selected_image:0, 
        name: 'Sophia Neville',   age:26, nearby:68, school:'Havard Raw School',
        aboutme:'This is the Sophia Neville\'s Profile.',
        action:1,
        star:0,CAP:'B', expire_days:3,assigned_date:'2017-1-12',  selected:false
      }, 
      {
        bagel_id:"T0000015",
        images:['Images/15.jpg'], selected_image:0, 
        name: 'Paris Osorio',     age:23, nearby:32, school:'Havard Raw School',
        aboutme:'This is the Paris Osorio\'s Profile.',
        action:2,
        star:1,CAP:'T', expire_days:1,assigned_date:'2017-1-9',  selected:false
      }, 
      {
        bagel_id:"C0000016",
        images:['Images/16.jpg'], selected_image:0, 
        name: 'Emelia Penn',     age:22, nearby:53, school:'Havard Raw School',
        aboutme:'This is the Emelia Penn\'s Profile.',
        action:2,
        star:1,CAP:'C', expire_days:3,assigned_date:'2017-1-16', selected:false
      }, 
      {
        bagel_id:"T0000017",
        images:['Images/17.jpg'], selected_image:0, 
        name: 'Mittie Quintanilla', age:20, nearby:28, school:'Havard Raw School',
        aboutme:'This is the Mittie Quintanilla\'s Profile.',
        action:1,
        star:1,CAP:'T', expire_days:2,assigned_date:'2017-1-10', selected:false
      }, 
      {
        bagel_id:"T0000018",
        images:['Images/18.jpg'], selected_image:0, 
        name: 'Ashlynn Renteria',       age:25, nearby:92, school:'Havard Raw School',
        aboutme:'This is the Ashlynn Renteria\'s Profile.',
        action:0,
        star:0,CAP:'T', expire_days:3,assigned_date:'2017-1-3', selected:false
      }, 
      {
        bagel_id:"T0000019",
        images:['Images/19.jpg'], selected_image:0, 
        name: 'Logan Shelley',      age:21, nearby:22, school:'Havard Raw School',
        aboutme:'This is the Logan Shelley\'s Profile.',
        action:0,
        star:1,CAP:'T', expire_days:1,assigned_date:'2017-1-11', selected:false
      }, 
      {
        bagel_id:"B0000020",
        images:['Images/20.jpg'], selected_image:0, 
        name: 'Paisley Tracy',   age:26, nearby:122,school:'Havard Raw School',
        aboutme:'This is the Paisley Tracy\'s Profile.',
        action:0,
        star:1,CAP:'B', expire_days:3,assigned_date:'2017-1-9', selected:false
      }, 
      {
        bagel_id:"T0000021",
        images:['Images/21.jpg'], selected_image:0, 
        name: 'Kiana Utley',     age:23, nearby:32, school:'Havard Raw School',
        aboutme:'This is the Kiana Utley\'s Profile.',
        action:0,
        star:0,CAP:'T', expire_days:1,assigned_date:'2017-1-11', selected:false
      }, 
      {
        bagel_id:"C0000022",
        images:['Images/22.jpg'], selected_image:0, 
        name: 'Alexus Vargas',     age:22, nearby:52, school:'Havard Raw School',
        aboutme:'This is the Alexus Vargas\'s Profile.',
        action:0,
        star:0,CAP:'C', expire_days:3,assigned_date:'2017-1-6', selected:false
      }, 
      {
        bagel_id:"T0000023",
        images:['Images/23.jpg'], selected_image:0, 
        name: 'Cristina Wesley', age:20, nearby:72, school:'Havard Raw School',
        aboutme:'This is the Cristina Wesley\'s Profile.',
        action:0,
        star:1,CAP:'T', expire_days:2,assigned_date:'2017-1-12', selected:false
      }, 
      {
        bagel_id:"C0000024",
        images:['Images/24.jpg'], selected_image:0, 
        name: 'Jordin Yeager',       age:25, nearby:82, school:'Havard Raw School',
        aboutme:'This is the Jordin Yeager\'s Profile.',
        action:0,
        star:0,CAP:'C', expire_days:3,assigned_date:'2017-1-12', selected:false
      }      
    ]

    #Action type 4 stands for “Woo Like”
    #Action type 3 stands for “Supler Like”
    #Action type 1 stands for “Like”
    #Action type 2 stands for “Pass”
    #Action type 0 stands for “Unviewed” (See CMB app workflow below for details!)

    $scope.msgs = [
      {
        bagel_id:"T0000001",
        chat_history:[
          {
            msg:"hi",
            sender:0,
            time:"2017-1-7 06:30:21",
            type:0
          },
          {
            msg:"hi",
            sender:1,
            time:"2017-1-7 06:30:31",
            type:0
          }
         ,
          {
            msg:"how are you today?",
            sender:0,
            time:"2017-1-7 06:31:11",
            type:0
          },
          {
            msg:"I am fine, and you?",
            sender:1,
            time:"2017-1-7 06:32:31",
            type:0
          },          
          {
            msg:"me, too!! I am very interested in your photo and profile. Can you meet in any time? If it's possible, let me know when & where can we have a meeting. thanks",
            sender:0,
            time:"2017-1-7 06:32:31",
            type:0
          },          
          {
            msg:"Okay. I will tell you tomorrow, I may busy today. thanks.",
            sender:1,
            time:"2017-1-7 06:32:31",
            type:0
          }           
        ]
      }
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
      
      
    $scope.init_message_page = ->
      $scope.init()
      max = 0
      for d,i in $scope.BagelsList
        if(d.star > 0)
          max = max+1

      p_ind = Math.round(Math.random() * (max - 1)) 
      p = 0
      for d,i in $scope.BagelsList
        if(d.star > 0)
          p++          
          if(p == p_ind)
            $scope.clickBagel(d)
            break
        if(p == p_ind)
          break

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
      if(bagel.action != 1 && bagel.action!=3 && bagel.action != 4)
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
    # favorite filter in Matches Page      
    $scope.filterBagelonMessagePage = (bagel) ->        
      if(bagel.action != 1 && bagel.action!=3 && bagel.action != 4)
        return false      
      if($scope.search_name.length > 0)
        if(bagel.name.indexOf($scope.search_name) < 0 )
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
          

    # Click Event in List page
    $scope.clickBagel = (bagel) ->
      if($scope.prev_bagel?)
        $scope.prev_bagel.selected = false
      bagel.selected = true
      $scope.prev_bagel = bagel
      $scope.carouselIndex=  0
    
    $scope.rebuildCarousel = ->               
      my_carousel.reset_all()      
    $scope.onClickBagel = (bagel) ->      
      if(bagel.CAP == "T")
        $scope.flag_woo_like = true
      else
        $scope.flag_woo_like = false
      if(bagel.CAP == "C")
        $scope.flag_super_like = true
      else
        $scope.flag_super_like = false
    
    $scope.onItemSelected = (bagel_id) ->      
      for d,i in $scope.BagelsList
        if(d.bagel_id == bagel_id)
          if(d.CAP == "T")
            $scope.flag_woo_like = true
          else
            $scope.flag_woo_like = false
          if(d.CAP == "C")
            $scope.flag_super_like = true
          else
            $scope.flag_super_like = false
          $scope.prev_bagel = d
          break
    $scope.addChatMsg = (str, date, time, sender) ->
      return
    $scope.SendChat = ->
      date = new Date
      date_d = date.Year()+"/"+date.Month() + "/" + date.Day()

      #$scope.addChatMsg($scope.str_chat_msg, )
    $scope.onNextImage =->      
      #$scope.parent.nextSlide()
      $scope.$$childHead.nextSlide()
    $scope.onPrevImage =->      
      #$scope.parent.nextSlide()
      $scope.$$childHead.prevSlide()

  ])