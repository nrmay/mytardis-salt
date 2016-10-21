SITE_STYLES = """
@font-face {
    font-family: "Museo";
    src: url("../../static/fonts/exljbris - Museo-300.otf");
    src: url("../../static/fonts/exljbris - Museo-500.otf");
    src: url("../../static/fonts/exljbris - Museo-700.otf");
    src: url("../../../static/fonts/exljbris - Museo-300.otf");
    src: url("../../../static/fonts/exljbris - Museo-500.otf");
    src: url("../../../static/fonts/exljbris - Museo-700.otf");
}

a {
     color: #dc291e; 
}

.page-header h1 {  
     color: #dc291e;  
     font-family: Museo, Verdana;
     text-transform: capitalize;   
 }
 
 h1 span {  
     font-family: Museo, Verdana;
     text-transform: capitalize;   
 }
 
.navbar {
     text-transform: uppercase;
}
 
.navbar .brand a { 
     display: none; 
}

.btn-primary, 
.btn-info, 
#login-button {
     color: white;
     background-color: grey;
     background-image: none;
}

.btn-primary:hover, 
.btn-info:hover,
#login-button:hover {
     color: black;
     background-color: grey;
} 

#experiments .accordion-group, 
.mydata .accordion-group {
     border-radius: 6px;
     background-color: rgba(0,0,0,0.1);
}
 
#experiments .accordion-inner, 
.mydata .accordion-inner {
     border-radius: 6px;
     background-color: rgba(0,0,0,0.2);
}
 
.nav-list > li > a:hover {
     border-radius: 6px;
     color: Black;
}
 
.nav-pills a:hover {
     color: Black;
     background-color: rgba(0,0,0,0.1);
}
 
.nav-pills .active a, 
.nav-pills .active a:hover {
     color: Black;
     background-color: rgba(0,0,0,0.1);
}

.alert, .alert-info {
     color: Black;
     border-color: rgba(220,41,30,0.5);
     background-color: rgba(220,41,30,0.1);
}
 
.badge-info {
     background-color: #598509;
}

"""
#  colour scheme
#  primary red = #dc291e = rgb(220,41,30)
#  seconaries 
#             default  dark    darkest  light   lightest
#     blue  = 147c86   245f64  065057   46b8c2  67bbc2
#     green = 8dcc1c   769936  598509   b1e651  bfe679 
#
# --- end of tardis.style_settings.py ---#