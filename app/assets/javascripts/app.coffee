aggregate_dating = angular.module('aggregate_dating',[
  	'templates',
  	'ngRoute',
    'ngResource',
  	'controllers',
  	# 'facebook',
    'ngFileUpload',
    'ngCookies',
    'angular-carousel',
    'luegg.directives',
    'ngMeta'
])

aggregate_dating.config([ '$routeProvider','ngMetaProvider'
  	($routeProvider,ngMetaProvider)->
    	$routeProvider
        .when('/',
          templateUrl: "index.html",
          controller: 'EmailSubscribe',
          data: {
            meta: {
              'title': 'Home page',
              'description': 'This is the description shown in Google search results'
            }
          }
        )
        .when('/admin-setting',
          templateUrl: "admin-setting.html",
          controller: 'Admin'
        )
        .when('/discover',
          templateUrl: "discover.html",
          controller: 'AggController'
        )
        .when('/login',
          templateUrl: "login.html",
          controller: 'LoginController'
        )
        .when('/messages',
          templateUrl: "messages.html",
          controller: 'AggController'
        )
        .when('/matches',
          templateUrl: "matches.html",
          controller: 'AggController'
        )        
        .when('/account',
          templateUrl: "account.html",
          controller: 'AggController'
        )
])
.run ['ngMeta'
  (ngMeta) ->
    ngMeta.init()
]
# aggregate_dating.config([ '$facebookProvider',
#  	($facebookProvider)->
#       	$facebookProvider
#         .init({
#             appId: '1609654029341787'
#         })
# ])

aggregate_dating.config(['$qProvider', 
  ($qProvider)->
    $qProvider.errorOnUnhandledRejections(false);
])


controllers = angular.module('controllers',[])

controllers.controller("LoginController", [ '$scope', '$rootScope', '$routeParams', '$location', '$http', '$resource', '$timeout'
  ($scope, $rootScope, $routeParams, $location, $http, $resource, $timeout)->
    # $scope.fb_login_flag = false 
    # $scope.loginFacebook = ->
    #   $scope.fb_login_flag = true
    #   $facebook.login(scope: 'email').then ((response) ->        
    #     $rootScope.MyAuthInfo.fbToken = response.authResponse.accessToken
    #     $rootScope.MyAuthInfo.fbUserID = response.authResponse.userID
    #     $scope.fbToken = response.authResponse.accessToken
    #     $scope.fbUserID = response.authResponse.userID 
    #     $facebook.api('/me').then((response) ->
    #         $rootScope.MyAuthInfo.fbName = response.name;
    #         $rootScope.MyAuthInfo.fbPhoto = "http://graph.facebook.com/"+response.id+"/picture"
    #         console.log $rootScope.MyAuthInfo.fbPhoto
    #         $scope.fb_login_flag = false
    #         $scope.loginTinder()
    #     )           
    # ), (response) ->
    #     console.log 'FB Login Error', response

    $rootScope.MyAuthInfo = []

    $scope.setFBTokenForHappn =->
      $rootScope.MyAuthInfo.fbTokenForHappn = $scope.user_fb_token_for_happn        
      $scope.loginHappn()

    $scope.setFBTokenForCMB = ->
      #show loading icon
      $rootScope.MyAuthInfo['fbToken'] = $scope.user_fb_token_for_cmb
      $scope.loginCMB()

    # $scope.loginTinder = ->
    #   $scope.tinderInfo = [] 
    #   $scope.tinder_login_flag = true
    #   Tinder = $resource('/tinder', { format: 'json' })
    #   Tinder.query(fbToken: $scope.fbToken, fbUserID: $scope.fbUserID , (results) -> 
    #     $scope.tinderInfo = results        
    #     if( results[0].Result == "success" )        
    #       console.log "Tinder Login Success"
    #       $("#tinder .Checked").show();
    #       $("#tinder .UnChecked").hide();
    #     else
    #       console.log "Tinder Login Failed"
    #       $("#tinder .UnChecked").show();
    #       $("#tinder .Checked").hide();
    #     $scope.tinder_login_flag = false
    #     $scope.loginCMB()
    #   )

    $scope.loginCMB = ->
      #login with CMB
      #CURL commands:
      # 1. curl https://api.coffeemeetsbagel.com/profile/me -H "App-version: 779" -H
      $scope.cmb_logging_in = true

      $rootScope.MyAuthInfo.cmbInfo = [] 

      Cmb = $resource('/cmb', { format: 'json' })
      Cmb.query(fbToken: $rootScope.MyAuthInfo.fbToken , (results) ->         

        #results of query
        console.log results[0]

        if( results[0].loginResult == "success" )        
          # console.log "CMB Login Success"
          $rootScope.MyAuthInfo.cmbInfo.profile_id = results[0].jsonObj.profile_id
          $rootScope.MyAuthInfo.cmbInfo.sessionid = results[0].sessionid        
          
          # $("#cmb .Checked").show();
          # $("#cmb .UnChecked").hide();
          
          $location.path('/discover')
        else
          # console.log "CMB Login Failed"
          # $("#cmb .UnChecked").show();
          # $("#cmb .Checked").hide();
          alert("CMB Login Failed")
        
        # $scope.cmb_logging_in = "false"
        # $scope.loginBumble()        
      )

    $scope.loginHappn = ->
      $scope.happn_login_flag = true
      $rootScope.MyAuthInfo.happnInfo = [] 
      Happn = $resource('/happn', { format: 'json' })
      Happn.query(fbToken: $rootScope.MyAuthInfo.fbTokenForHappn , (results) ->         
        console.log results[0]
        if( results[0].loginResult == "success" )        
          console.log "Happn Login Success"
          $rootScope.MyAuthInfo.cmbInfo.profile_id = results[0].jsonObj.profile_id
          $rootScope.MyAuthInfo.cmbInfo.sessionid = results[0].sessionid        
          
          $location.path('/discover')
        else
          console.log "Happn Login Failed"          
          
        $scope.happn_login_flag = false
        # $scope.loginBumble()        
      )

    # $scope.loginBumble = ->
    #   #login with CMB
    #   #CURL commands:
    #   # 1. curl https://api.coffeemeetsbagel.com/profile/me -H "App-version: 779" -H
    #   $scope.bumble_login_flag = true
    #   $rootScope.MyAuthInfo.bumbleInfo = [] 
    #   Bumble = $resource('/bumble', { format: 'json' })
    #   Bumble.query(fbToken: $rootScope.MyAuthInfo.fbToken , (results) ->         
    #     if( results[0].loginResult == "success" )        
    #       console.log "Bumble Login Success"
    #       $rootScope.MyAuthInfo.bumbleInfo.profile_id = results[0].jsonObj.profile_id
    #       $rootScope.MyAuthInfo.bumbleInfo.sessionid = results[0].sessionid        
    #       $("#bumble .Checked").show();
    #       $("#bumble .UnChecked").hide();          
    #     else
    #       console.log "Bumble Login Failed"
    #       $("#bumble .UnChecked").show();
    #       $("#bumble .Checked").hide();
    #     $scope.bumble_login_flag = false                
    #     $timeout ->
    #       $location.path('/main');
    #     , 2000;
        
    #   )
])

controllers.controller("AggController", [ '$scope', '$rootScope', '$routeParams', '$location', '$http', '$resource', '$cookies', '$cookieStore', 'Upload', '$timeout','ngMeta'
  ($scope, $rootScope, $routeParams, $location, $http, $resource, $cookies, $cookieStore, Upload, $timeout, ngMeta)->
    
    $scope.login_flag = false
    $scope.show_filter_flag = false
    $scope.prev_bagel = null

    #if(not $rootScope.MyAuthInfo.fbToken?)
    #  $location.path('/login')
    $scope.page_number = 0      # 2:discover
                                # 3:message
                                # 4:matches
                                # 5:account
    $scope.matches_count = 0
    $scope.discover_count = 0

    $rootScope.bagels = [];
                                
    vm = this
    $scope.flag_t = true   #tinder_flag
    $scope.flag_o = true   #Okpid_flag 
    $scope.flag_p = true   #POF_flag 
    $scope.flag_b = true   #Bumble_flag 
    $scope.flag_c = true   #CMB_flag
    $scope.flag_f_r = false #Favorite flag
    $scope.flag_r_r = false #Recent flag
    $scope.flag_e_r = false #Expiring flag
    
    $scope.account_added_flag   = false    #Added
    $scope.account_network_msg   = ""    #Added


    $scope.account_tinder_flag   = false
    $scope.account_happn_flag    = false
    $scope.account_cmb_flag      = false
    $scope.account_okcupid_flag  = false
    $scope.account_bumble_flag   = false

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
            msg:"Okay. I will tell you tomorrow, I can be busy today. thanks.",
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

      jQuery('#filter_dlg').click (event) ->
        event.stopPropagation()
        return

      jQuery('#small-mark').click (event) ->
        event.stopPropagation()
        return

      # console.log $scope.BagelsList
      $scope.getBagels()
      
      # today = new Date
      # for bagel, i in $scope.BagelsList
      #   if(bagel.action == 1 || bagel.action == 3 || bagel.action == 4 )
      #     $scope.matches_count++
      #   if(bagel.action == 0)
      #     $scope.discover_count++
      #   d1 = new Date(bagel.assigned_date)
      #   diff = today-d1
      #   bagel.expire_days = Math.floor(diff / (3600 * 24*1000))

        
    $scope.init_meta_tag = (link_str) ->
      Admin = $resource('/admin/get_page_uri', { format: 'json' })
      Admin.query(link: link_str, (results) ->     
        seo = results[0].jsonObj
        ngMeta.setTitle(seo[0].page_title)
        ngMeta.setTag('keywords', seo[0].page_keywords)
        ngMeta.setTag('description', seo[0].page_description)
        ngMeta.setTag('url', seo[0].url)
        ngMeta.setTag('fb_title', seo[0].fb_title)
        ngMeta.setTag('fb_description', seo[0].fb_description)
        ngMeta.setTag('twitter_title', seo[0].twitter_title)
        ngMeta.setTag('twitter_description', seo[0].twitter_description)
      )  
    $scope.init_matches_page = ->
      $scope.init_meta_tag("/matches")
      $scope.init() 
      $scope.page_number = 4

    $scope.init_discover_page = ->
      $scope.init_meta_tag("/discover")
      $scope.init()
      $scope.page_number = 2 

    $scope.init_message_page = ->    
      $scope.init_meta_tag("/message")
      $scope.init()
      $scope.page_number = 3
      $scope.select_bagel_by_random()


    $scope.init_account = ->

      $scope.init_meta_tag("/account")
      $scope.page_number = 5

    $scope.select_bagel_by_random = ->      
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
      
    $scope.getBagels = ->
      if(not $rootScope.MyAuthInfo.fbToken?)
        alert "You haven't logged into CMB yet."
        return

      $scope.bagels_flag = true
      $scope.BagelsInfo = []

      Cmb = $resource('/cmb/get_bagels', { format: 'json' })
      Cmb.query(fbToken: $rootScope.MyAuthInfo.fbToken, sessionid: $rootScope.MyAuthInfo.cmbInfo.sessionid, (results) -> 

        $rootScope.bagels = results[0].jsonObj.results

        console.log $rootScope.bagels

        idx = 0
        while $rootScope.bagels.length > 0 && $rootScope.bagels.length > idx
          # console.log idx
          # console.log $rootScope.bagels.length
          # console.log $rootScope.bagels[idx]
          
          if $rootScope.bagels[idx].action  == 0 || $rootScope.bagels[idx].action == 3
            idx = idx + 1
          else
            $rootScope.bagels.splice(idx, 1)  
        
        $scope.showNextBagel()
      )

      console.log "End of GetBagels"

    $scope.showNextBagel = () ->

      if $rootScope.bagels.length > 0 
        console.log $rootScope.bagels.length

        newList = []

        $scope.setActionToBagel(3)

        for d,i in $rootScope.bagels[0].profile.photos
          # console.log d

          # newList.push {images:[d.profile.photos[0].iphone_fullscreen], selected_image:0, CAP:'T'}
          
          newList.push {
            bagel_id:"C0000022",
            images:[d.iphone_fullscreen], selected_image:0, 
            name: 'Alexus Vargas',     age:22, nearby:52, school:'Havard Raw School',
            aboutme:'This is the Alexus Vargas\'s Profile.',
            action:0,
            star:0,CAP:'C', expire_days:3,assigned_date:'2017-1-6', selected:false
          }

        console.log "NEW LIST"
        console.log newList

        $scope.BagelsList = newList
      
      $timeout ->
        $scope.rebuildCarousel()
      , 100;


    $scope.onLike = () ->
      console.log 'Inside onLike'

      $scope.setActionToBagel(1)

    $scope.onPass = () ->
      console.log 'Inside onPass'

      $scope.setActionToBagel(2)


    $scope.setActionToBagel = (actionNum) ->
      if $rootScope.bagels.length <= 0
        return

      Cmb = $resource('/cmb/set_bagel', { format: 'json' })

      console.log "Bagel ID"
      console.log $rootScope.bagels[0].id
      console.log actionNum

      Cmb.query(fbToken: $rootScope.MyAuthInfo.fbToken, sessionid: $rootScope.MyAuthInfo.cmbInfo.sessionid, userid: $rootScope.bagels[0].id, actionNum: actionNum, (results) -> 

        console.log results

        if actionNum != 3
          $rootScope.bagels.splice(0, 1)  # remove first bagel. it is shown currently        
          $scope.showNextBagel()
      )


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

      # LOAD Carousel at loading
      # if($scope.page_number == 2)
      #   #Discover Page
      #   $timeout ->
      #     $scope.rebuildCarousel()
      #   , 100;

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

    $scope.on_click_happn_account_page =->
      $scope.account_happn_flag   = !$scope.account_happn_flag       
      $scope.account_added_flag   = $scope.account_happn_flag
      $scope.account_network_msg  = "Happn"

    $scope.on_click_tinder_account_page =->
      $scope.account_tinder_flag  = !$scope.account_tinder_flag       
      $scope.account_added_flag   = $scope.account_tinder_flag
      $scope.account_network_msg  = "Tinder"

    $scope.on_click_cmb_account_page =->
      $scope.account_cmb_flag     = !$scope.account_cmb_flag 
      $scope.account_added_flag   = $scope.account_cmb_flag
      $scope.account_network_msg  = "Coffee Meets Bagel"

    $scope.on_click_okcupid_account_page =->
      $scope.account_okcupid_flag = !$scope.account_okcupid_flag 
      $scope.account_added_flag   = $scope.account_okcupid_flag
      $scope.account_network_msg  = "OKCupid"

    $scope.on_click_bumble_account_page =->
      $scope.account_bumble_flag  = !$scope.account_bumble_flag 
      $scope.account_added_flag   = $scope.account_bumble_flag
      $scope.account_network_msg  = "Bumble"


  ])

controllers.controller("EmailSubscribe", [ '$scope', '$routeParams', '$location', '$http', '$resource','$cookies','$cookieStore', 'Upload', '$timeout','ngMeta'
  ($scope,$routeParams,$location,$http,$resource,$cookies,$cookieStore, Upload, $timeout, ngMeta)->
    
    Admin = $resource('/admin/get_page_uri', { format: 'json' })
    Admin.query(link: '/', (results) ->       
      seo = results[0].jsonObj
      console.log seo[0]
      ngMeta.setTitle(seo[0].page_title)
      ngMeta.setTag('keywords', seo[0].page_keywords)
      ngMeta.setTag('description', seo[0].page_description)
      ngMeta.setTag('url', seo[0].url)
      ngMeta.setTag('fb_title', seo[0].fb_title)
      ngMeta.setTag('fb_description', seo[0].fb_description)
      ngMeta.setTag('twitter_title', seo[0].twitter_title)
      ngMeta.setTag('twitter_description', seo[0].twitter_description)
    )
    
    $scope.onEmailSubscribe = ->  
      email_subscriber = jQuery(".subscribe_email").val()    
      atpos       = email_subscriber.indexOf("@")
      dotpos      = email_subscriber.lastIndexOf(".")
      WhiteSpace  = email_subscriber.indexOf(' ')
      email_flag  = 1

      if atpos < 1 or dotpos < atpos + 2 or dotpos + 2 >= email_subscriber.length or WhiteSpace >= 0
        jQuery("#subscribe_status").html("Not a valid e-mail address.")
        jQuery("#subscribe_status").addClass("error")
        $timeout ->
          jQuery("#subscribe_status").removeClass("error")
          jQuery("#subscribe_status").html("Leave your email and we’ll add you to our beta invite list")
          jQuery(".subscribe_email").focus()
        , 2000
        email_flag = 0

      if( email_flag ==1 ) 
        MailChimp = $resource('/mailchimp/email_subscriber', { format: 'json' })
        MailChimp.query(email: email_subscriber, (results) -> 
          jQuery(".result").html("")
          jQuery(".email").html("<p class='thankyou'><label class='ok'>&nbsp;</label>Thank you! Your email has been submitted.</p>")
        )
  ])


controllers.controller("Admin", [ '$scope', '$routeParams', '$location', '$http', '$resource','$cookies','$cookieStore', 'Upload', '$timeout'
  ($scope,$routeParams,$location,$http,$resource,$cookies,$cookieStore, Upload, $timeout)->

    $scope.email_list = []    
    $scope.page_uris = []
    $scope.page_types = ["Admin Page","Front Page","Admin Page"]
    $scope.edit_id = 0          # 0: Add New
                                # >0: Update
    $scope.seo_id = 0
    $scope.seo_link_id = 0
    $scope.help_1_flag  = false
    $scope.prev_row_obj = null
    $scope.save_seo_flag = false

    MailChimp = $resource('/mailchimp/email_subscriber_list', { format: 'json' })
    MailChimp.query((results) ->       
      $scope.email_list = results[0].jsonObj
    )

    Admin = $resource('/admin/get_page_uris', { format: 'json' })
    Admin.query((results) ->       
      $scope.page_uris = results[0].jsonObj
    )

    $scope.onDeleteEmail = (email_obj) ->
      if confirm "Do you want to delete the email?"
        MailChimp = $resource('/mailchimp/delete_email', { format: 'json' })
        MailChimp.query(id: $email_obj.id,(results) ->       
          $scope.email_list = results[0].jsonObj
        )
    $scope.onAdd = ->
      if($scope._add_page_link == undefined)
        alert "Please input Page Link"
        return
      page_uri = {}
      page_uri.id = 0      
      page_uri.page_uri = $scope._add_page_link
      page_uri.page_type = jQuery("#_add_page_type").val()
      uri = '/admin/add_page_uri'
      if ($scope.edit_id > 0)
        uri = '/admin/update_page_uri'
        page_uri.id = $scope.edit_id

      Admin = $resource(uri, { format: 'json' })
      Admin.query(link: page_uri, (results) ->       
        $scope.page_uris = results[0].jsonObj
        result = results[0].result
        if(result != "OK")        
          alert result
        else
          $scope._add_page_link = ""
          jQuery("#btn_add").removeClass("btn-success").addClass("btn-primary")
          jQuery("#btn_add").html("Add")
          $scope.edit_id = 0        
      )
    $scope.onEditLink = (link) ->
      $scope.edit_id = link.id
      jQuery("#btn_add").removeClass("btn-primary").addClass("btn-success")
      jQuery("#btn_add").html("Update")
      $scope._add_page_link = link.page_uri
      jQuery("#_add_page_type").val(link.page_type)
    $scope.onDeleteLink = (link) ->
      if confirm "Do you want to delete the link?"
        Admin = $resource('/admin/delete_page_uri', { format: 'json' })
        Admin.query(id: link.id,(results) ->       
          $scope.page_uris = results[0].jsonObj
        )
    $scope.onSEOSetting = (link) ->      
      if($scope.prev_row_obj != null)
        jQuery($scope.prev_row_obj).removeClass("selected")
      jQuery("#link_row_id_"+link.id).addClass("selected")
      $scope.prev_row_obj = jQuery("#link_row_id_"+link.id)
      $scope.seo_link_id = link.id
      Admin = $resource('/admin/select_page_uri', { format: 'json' })
      Admin.query(id: link.id,(results) ->       
        seo = results[0].jsonObj
        
        if seo.length == 0
          $scope.seo_id = 0
          $scope.seo_title = ""
          $scope.seo_url = ""
          $scope.seo_description = ""
          $scope.seo_keyword = ""
          $scope.fb_title = ""
          $scope.fb_description = ""
          $scope.twitter_title = ""
          $scope.twitter_description = ""
        else
          $scope.seo_id                 = seo[0].id
          $scope.seo_title              = seo[0].page_title
          $scope.seo_url                = seo[0].url
          $scope.seo_description        = seo[0].page_description
          $scope.seo_keyword            = seo[0].page_keywords
          $scope.fb_title               = seo[0].fb_title
          $scope.fb_description         = seo[0].fb_description
          $scope.twitter_title          = seo[0].twitter_title
          $scope.twitter_description    = seo[0].twitter_description

      )

    $scope.onSaveSEO = ->      
      seo = {}
      if($scope.seo_title == undefined)
        $scope.seo_title = ""
      if($scope.seo_url == undefined)
        $scope.seo_url = ""
      if($scope.seo_description == undefined)
        $scope.seo_description = ""
      if($scope.seo_keyword == undefined)
        $scope.seo_keyword = ""
      if($scope.fb_title == undefined)
        $scope.fb_title = ""
      if($scope.fb_description == undefined)
        $scope.fb_description = ""
      if($scope.twitter_title == undefined)
        $scope.twitter_title = ""
      if($scope.twitter_description == undefined)
        $scope.twitter_description = ""

      seo.id                    = $scope.seo_id
      seo.uri_id                = $scope.seo_link_id
      seo.page_title            = $scope.seo_title
      seo.url                   = $scope.seo_url
      seo.page_description      = $scope.seo_description
      seo.page_keywords         = $scope.seo_keyword
      seo.fb_title              = $scope.fb_title
      seo.fb_description        = $scope.fb_description
      seo.twitter_title         = $scope.twitter_title
      seo.twitter_description   = $scope.twitter_description
      $scope.save_seo_flag = true
      Admin = $resource('/admin/save_seo_data', { format: 'json' })
      Admin.query(seo_obj: seo,(results) ->   

        seo = results[0].jsonObj
        if seo.length == 0
          $scope.seo_id = 0
          $scope.seo_title = ""
          $scope.seo_url = ""
          $scope.seo_description = ""
          $scope.seo_keyword = ""
          $scope.fb_title = ""
          $scope.fb_description = ""
          $scope.twitter_title = ""
          $scope.twitter_description = ""

        else
          $scope.seo_id               = seo[0].id
          $scope.seo_title            = seo[0].page_title
          $scope.seo_url              = seo[0].url
          $scope.seo_description      = seo[0].page_description
          $scope.seo_keyword          = seo[0].page_keywords
          $scope.fb_title             = seo[0].fb_title
          $scope.fb_description       = seo[0].fb_description
          $scope.twitter_title        = seo[0].twitter_title
          $scope.twitter_description  = seo[0].twitter_description
        $scope.save_seo_flag = false

      )
    $scope.onClickHelp1 = ->
      $scope.help_1_flag  = !$scope.help_1_flag

  ])
