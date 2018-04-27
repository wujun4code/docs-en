<!doctype html>

<html>

<head>

{% include 'templates/include/head.html' %}
<style>
.algolia-autocomplete {
  min-width: 50%;
}
* {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, "PingFang SC", "Microsoft Yahei", "WenQuanYi Micro Hei", ui-icon, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
}
.doc-content {
  margin-bottom: 56px;
}
.course-about {
  font-size: 13px;
  color: #aaa; 
  max-width: 25em;
}
.form-group {
  position: relative;
}
#site-search {
  /* border-width: 0 0 1px 0;
  border-style: solid;
  border-color: #666; */
  border: 1px solid #999;
  border-radius: 3px;
  text-align: center;
  background: none;
  font-size: 16px;
}
#site-search:focus {
  box-shadow: none;
}
.scrollspy {
  /*margin-bottom: 40px;*/
  font-size: 16px;
  background-color: #fff;
  position: relative;
}
.scrollspy ul {
  border: none;
  display: inline-block;
}
.scrollspy li {
  display: inline-block;
  margin-right: 6px;
}
.scrollspy li:last-child {
  margin-right: 0;
}
.scrollspy li>a {
  display: inline-block;
  padding: 20px 14px 19px;
  margin-bottom: -1px;
  line-height: 20px;
  border-bottom: 1px solid transparent;
  background: 0;
  white-space: nowrap;
}
.scrollspy ul>li>a:hover,
.scrollspy ul>li>a:active,
.scrollspy ul>li>a:focus,
.scrollspy .active a {
  background-color: transparent;
  border-bottom-color: #2c97e8;
}

.affix {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 10;
  box-shadow: 0 1px 1px rgba(0, 0, 0, .15);
}
.tags {
  margin: 8px 0;
}
.tags>li {
  display: inline-block;
}
.tags>li>a {
  min-width: 90px;
}
.tags>li>a {
  padding: 3px;
  font-size: 13px;
  background-color: #f1f8ff;
  margin: 2px 0;
  display: block;
  text-align: center;
  line-height: 1.8;
  text-decoration: none;
  border-radius: 3px;
}
.tags>li>a {
  line-height: 1.8;
  white-space: nowrap;
}
.tags>li>a:hover {
  background-color: #2c97e8;
  color: #fff;
}
.tags>li::after,
.tags>li:last-child::after {
  content: none!important;
}
.doc-home-title {
  padding-bottom: 0;
  padding-top: 40px;
}
.scrollspy .nav {
  visibility: hidden;
}
.scrollspy.loaded .nav {
  visibility: visible
}
.doc-home-title .nav-pills > li{
  float: none;
  display: inline-block;
}
.doc-home-title .doc-hero-links {
  margin-bottom: 0;
  margin-top: 1em;
}
.doc-home-title .doc-quick-start-btn {
  color: #bbb;
  min-width: 10em;
  font-weight: 400;
  border: none;
}
.doc-home-title .doc-quick-start-btn:hover {
    color: #333;
    border-color: #333;
}
.doc-home-title .active .doc-quick-start-btn {
    color: #3090e4;
    border-color: #3090e4;
}
</style>
</head>

<!-- <body id="home" class="dashboard-init" ng-cloak ng-controller="AppCtrl" data-spy="scroll" data-target=".scrollspy"> -->
<body id="home" class="dashboard-init" ng-cloak ng-controller="AppCtrl">
{% include 'templates/include/header.html' %}

<!-- <div class="container-fluid doc-content <%= node %> platform-as-tab" id="content"> -->
<div class="container doc-content <%= node %>" id="content">
  {{body}}
</div>
<!-- .container-fluid, .doc-content -->
{% include 'templates/include/common-footer.html' %}

{% include 'templates/include/footer.html' %}

<script type="text/javascript">
// $(document).ready(function(){
//   $('a[data-toggle="pill"]').on('show.bs.tab', function (e) {
//     var $this = $(e.target),
//         source = $this.attr('href'),
//         pane = $this.attr('data-target');
//     //console.log($this, source, pane, source.charAt(0) !== '#',$(pane).is(':empty'));
//     if( source.charAt(0) !== '#' && $(pane).is(':empty') ) {  
//       $.get(source, function(data) {
//           $(pane).html($(data).find('#backbone').html());
//       });
//       //console.log("filled");
//     }
//     return true;
//   });
// });

// get nav items ready for scrollspy
// $(window).load(function() {
//   $('#section-nav').affix({
//       offset: {
//         top: $('nav').outerHeight(true) + $('.doc-home-title').outerHeight(true)
//       }
//   }).addClass('loaded');
// });
</script>
</body>
</html>
