aggregate_dating = angular.module('aggregate_dating',[
  	'templates',
  	'ngRoute',
    'ngResource',
  	'controllers',
  	'facebook',
    'ngFileUpload'
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
        .when('/',
          templateUrl: "list.html"
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


controllers.controller("AggController", [ '$scope', '$routeParams', '$location', '$facebook', '$http', '$resource', 'Upload'
  ($scope,$routeParams,$location,$facebook,$http,$resource, Upload)->
    
    $scope.login_flag = false
    console.log MyAuthInfo.fbToken
    #if(not MyAuthInfo.fbToken?)
    #  $location.path('/login')

    $scope.BagelsList = [
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':0,'star':1}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':0,'star':1}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':0,'star':1}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':0,'star':1}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/1.jpg', 'name': 'Maria Vann',      'age':21, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/2.jpg', 'name': 'Leslie Lawson',   'age':26, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/3.jpg', 'name': 'Dora Thomas',     'age':23, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}, 
      {'image':'Images/4.jpg', 'name': 'Karen Olsen',     'age':22, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':0,'star':0}, 
      {'image':'Images/5.jpg', 'name': 'Mittie Phillips', 'age':20, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':1}, 
      {'image':'Images/6.jpg', 'name': 'Dori Moss',       'age':25, 'nearby':2,'school':'Havard Raw School','aboutme':'Now that I’ve given you the pep talk','border':1,'star':0}
      
    ]

    $scope.loginFacebook = ->
      #   Login with FaceBook           
      $scope.login_flag = true
      $facebook.login(scope: 'email').then ((response) ->
        authtoken = response.authResponse.accessToken
        console.log 'FB Login Success', authtoken
        console.log response.authResponse
        $scope.fbToken = authtoken
        $scope.fbUserID = response.authResponse.userID
        $scope.loginCMB(authtoken)
    ), (response) ->
        console.log 'FB Login Error', response
	
    $scope.loginCMB = (authtoken) ->
      #login with CMB
      #CURL commands:
      # 1. curl https://api.coffeemeetsbagel.com/profile/me -H "App-version: 779" -H
      $scope.cmbInfo = [] 
      Cmb = $resource('/cmb', { format: 'json' })
      Cmb.query(fbToken: authtoken , (results) -> 
        $scope.cmbInfo = results
        $scope.sessionid = results[0].sessionid
        $scope.login_flag = false
      )
    $scope.getMyProfile = ->
      # Set my profile
      # Check Input values
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      # Set values and Send to Server
      $scope.get_profile_flag = true

      Cmb = $resource('/cmb/get_profile', { format: 'json' })
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.profileInfo = results        
        $scope.userid = results[0].jsonObj.id
        $scope.user_gender = results[0].jsonObj.gender
        $scope.user_name = results[0].jsonObj.full_name
        $scope.user_email = results[0].jsonObj.user__email        
        $scope.user_criteria_gender = results[0].jsonObj.criteria__gender        
        $scope.user_birthday = new Date(results[0].jsonObj.birthday)
        $scope.firebaseToken = results[0].jsonObj.firebase_token
        $scope.get_profile_flag = false         
      )
      
    
    $scope.setMyProfile = ->
      # Set my profile
      # Check Input values
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      if(not $scope.user_name?)
        alert "Please Input 'User Name'."
        return
      if(not $scope.user_gender?)
        alert "Please Input 'User Gender'."
        return
      if($scope.user_gender!= "f" && $scope.user_gender!= "m")
        alert "'User Gender' must be 'm/f'."
        return
      if(not $scope.user_criteria_gender?)
        alert "Please Input 'Criteria Gender'."
        return
      if($scope.user_criteria_gender!= "f" && $scope.user_criteria_gender!= "m")
        alert "'Criteria Gender' must be 'm/f'."
        return
      if(not $scope.user_email?)
        alert "Please Input 'User Email'."
        return
      # Set values and Send to Server
      $scope.profile_flag = true
      $scope.user = {}
      $scope.user.name = $scope.user_name
      $scope.user.id = $scope.userid
      $scope.user.gender = $scope.user_gender
      $scope.user.birthday = $scope.user_birthday
      $scope.user.email = $scope.user_email
      $scope.user.criteria_gender = $scope.user_criteria_gender 

      Cmb = $resource('/cmb/set_profile', { format: 'json' })
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, user: $scope.user , (results) -> 
        $scope.setProfileInfo = results
        $scope.profile_flag = false
        console.log 'data OK'   
      )
      
    $scope.setBagels = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return     
      $scope.bagels_flag = true
      $scope.BagelsInfo = [] 
      Cmb = $resource('/cmb/get_bagels', { format: 'json' })
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.BagelsInfo = results
        $scope.BagelInfo = {}
        $scope.BagelInfo.hex_id = results[0].jsonObj.current_token
        $scope.BagelInfo.cursor_after = results[0].jsonObj.cursor_after
        $scope.BagelInfo.cursor_before = results[0].jsonObj.cursor_before
        $scope.BagelInfo.more_after = results[0].jsonObj.more_after
        $scope.BagelInfo.more_before = results[0].jsonObj.more_before
        $scope.bagels_flag = false
        console.log 'Bagles OK'   
      )
    $scope.getBagelsHistory = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return    
         
      if(not $scope.BagelInfo?) || (not $scope.BagelInfo.hex_id?) 
        alert "Please Click 'Set Bagels'."
        return    
      $scope.bagels_history_flag = true
      $scope.BagelsList = [] 
      Cmb = $resource('/cmb/get_bagels_history', { format: 'json' })
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, bagel: $scope.BagelInfo, (results) -> 
        $scope.BagelsList = results    
        $scope.bagels_history_flag = false   
        console.log 'Bagles History OK'   
      )
    $scope.getResources = ->
      $scope.get_resources_flag = true
      Cmb = $resource('/cmb/get_resources', { format: 'json' })
      $scope.ResourceInfo = [] 
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.ResourceInfo = results
        $scope.get_resources_flag = false
        console.log 'ResourceOk'
      )

    $scope.photolabs = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      $scope.photolabs_flag = true
      $scope.PhotoLabs = []
      Cmb = $resource('/cmb/get_photolabs', { format: 'json' })
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.PhotoLabs = results
        $scope.photolabs_flag = false
        console.log 'get_photoLabs'
      )

    $scope.giveTake = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      $scope.give_take_flag = true
      $scope.girl_id = '2244848'
      $scope.GiveTaskResult = []
      Cmb = $resource('/cmb/give_take', { format: 'json' })      
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, customer_id: $scope.girl_id, (results) -> 
        $scope.GiveTaskResult = results
        $scope.give_take_flag = false
        console.log 'giveTake'
      )

    $scope.purchase = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      $scope.girl_id = '2244848'
      if(not $scope.item_count?)
        alert "Please Input 'Item Count'."
        return
      if(not $scope.item_name?)
        alert "Please Input 'Item Name'."
        return
      if(not $scope.expected_price?)
        alert "Please Input 'expected_price'."
        return
      if(not $scope.give_ten_id?)
        alert "Please Input 'Given ten id'."
        return
      $scope.purchase_flag = true
      $scope.Purchase = {}
      $scope.Purchase.item_name = $scope.item_name
      $scope.Purchase.item_count = $scope.item_count
      $scope.Purchase.expected_price = $scope.expected_price
      $scope.Purchase.give_ten_id = $scope.give_ten_id
      $scope.PurchaseResult = []
      Cmb = $resource('/cmb/purchase', { format: 'json' })      
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, purchase: $scope.Purchase, (results) -> 
        $scope.PurchaseResult = results
        $scope.purchase_flag = false
        console.log 'PurchaseOK'
      )

    $scope.report = ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      Cmb = $resource('/cmb/report', { format: 'json' })      
      $scope.report_num = "4"
      $scope.report_flag = true
      $scope.ReportResult = []
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.ReportResult = results
        $scope.report_flag = false
        console.log 'Report'
      )
    $scope.get_bundary_id = ->
      uniqueId = (length=8) ->
        id = ""
        id += Math.random().toString(36).substr(2) while id.length < length
        id.substr 0, length
      #var boundary_id = uniqueId(8) + "-" + uniqueId(4) + "-" + + uniqueId(4) + "-" + uniqueId(4) + "-" + uniqueId(12) 
      b_1 = uniqueId(8)
      b_2 = uniqueId(4)
      b_3 = uniqueId(4)
      b_4 = uniqueId(4)
      b_5 = uniqueId(12)
      #$scope.boundary_id = "#{b_1}-#{b_2}-#{b_3}-#{b_4}-#{b_5}"      
      return "#{b_1}-#{b_2}-#{b_3}-#{b_4}-#{b_5}"

    $scope.photo = ->           
      boundary_id = $scope.get_bundary_id()
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      if(not $scope.photo_position?)
        alert "Please Input Photo Position."
        return
      if(not $scope.photo_caption?)
        alert "Please Input Photo Caption."
        return
      #$file_name      
      #$file_photo_position
      #$file_photo_caption
    $scope.pickimg = (file) ->
      if(not $scope.fbToken?)
        alert "Please Click 'Login with Facebook'."
        return
      #$file_name 
      Cmb = $resource('/cmb/msg_login', { format: 'json' })      
      $scope.report_num = "4"
      $scope.report_flag = true
      $scope.ReportResult = []
      Cmb.query(fbToken: $scope.fbToken, sessionid: $scope.sessionid, (results) -> 
        $scope.ReportResult = results
        $scope.report_flag = false
        console.log 'Report'
      )    

      # upload on file select or drop
      # this is angular file upload
      # 
    $scope.upload = (file) ->
      console.log file
      Upload.upload({
          url: 'https://api.coffeemeetsbagel.com/photo',
          data: {"file": file, 'position': $scope.file_photo_position, "caption": $scope.file_photo_caption},
          headers: {
            "AppStore-Version": "3.4.1.779",
            "App-Version": "779",
            "Client": "Android",
            "Content-Type": "multipart/form-data",
            "Access-Control-Allow-Origin": "*",
            "Facebook-Auth-Token": $scope.fbToken,
            "Cookie": "sessionid="+$scope.sessionid 
          }
      }).then((resp) ->
          console.log 'Success ' + resp.config.data.file.name + 'uploaded. Response: ' + resp.data
      , (resp) ->
          console.log('Error status: ' + resp.status);
      , (evt) ->
          $scope.progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
          console.log 'progress: ' + $scope.progressPercentage + '% ' + evt.config.data.file.name
      )
    $scope.loginFacebookForTinder = ->           
      if(not $scope.fbToken?)
        $scope.tinder_login_flag = true
        $facebook.login(scope: 'email').then ((response) ->
          authtoken = response.authResponse.accessToken
          console.log response.authResponse
          $scope.fbToken = authtoken
          $scope.fbUserID = response.authResponse.userID  
          $scope.loginTinder()               
        ), (response) ->
            console.log 'FB Login Error', response
      else
        $scope.loginTinder()
    $scope.loginTinder = ->
      $scope.tinderInfo = [] 
      Tinder = $resource('/tinder', { format: 'json' })
      Tinder.query(fbToken: $scope.fbToken, fbUserID: $scope.fbUserID , (results) -> 
        $scope.tinderInfo = results        
        $scope.tinder_login_flag = false
      )
  ])
