{locale path="nextgen/locale" domain="partdb"}


{if !isset($ajax_request) || !ajax_request}
    <!DOCTYPE html>
    <!--suppress JSUnresolvedLibraryURL -->
<html lang="{if isset($lang)}{$lang}{else}en{/if}">
<head>
    {if isset($http_charset)}<meta charset={$http_charset}>
    {else}<meta charset="utf-8">{/if}

    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="apple-touch-icon" sizes="180x180" href="{$relative_path}icons/apple-touch-icon.png">
    <link rel="icon" type="image/png" href="{$relative_path}icons/favicon-32x32.png" sizes="32x32">
    <link rel="icon" type="image/png" href="{$relative_path}icons/favicon-16x16.png" sizes="16x16">
    <link rel="manifest" href="{$relative_path}icons/manifest.json">
    <link rel="mask-icon" href="{$relative_path}icons/safari-pinned-tab.svg" color="#5bbad5">
    <link rel="shortcut icon" href="{$relative_path}icons/favicon.ico">
    <meta name="msapplication-config" content="{$relative_path}icons/browserconfig.xml">
    <meta name="theme-color" content="#ffffff">

    <title>{$page_title}</title>

    <!-- Include Bootstrap or an Bootswatch theme -->
    {if !isset($custom_css)}
        <link href="{$relative_path}css/bootstrap.min.css" rel="stylesheet">
    {else}
        <link rel="stylesheet" href="{$relative_path}{$custom_css}">
    {/if}

    <!-- Include Awsome Font -->
    <link rel="stylesheet" href="{$relative_path}css/fontawesome-all.min.css">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->


    {if $debugging_activated}
    <!-- Checkboxes -->
    <link href="{$relative_path}css/awesome-bootstrap-checkbox.css" rel="stylesheet">

    <!-- Include Part-DB Theme -->
    <link href="{$relative_path}templates/{$theme}/nextgen.css" rel="stylesheet">

    {else}
    <!-- Checkboxes -->
    <link href="{$relative_path}css/awesome-bootstrap-checkbox.min.css" rel="stylesheet">

    <!-- Include Part-DB Theme -->
    <link href="{$relative_path}templates/{$theme}/nextgen.min.css" rel="stylesheet">
    {/if}


    <!-- Fileinput -->
    <link href="{$relative_path}vendor/kartik-v/bootstrap-fileinput/css/fileinput.min.css" media="all" rel="stylesheet"/>



    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="{$relative_path}vendor/components/jquery/jquery.min.js"></script>
    <!-- Popper.js (needed for BS4 tooltips) -->
    <script src="{$relative_path}js/popper/popper.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="{$relative_path}js/bootstrap.min.js"></script>

    <!-- Bootstrap select -->
    <link rel="stylesheet" href="{$relative_path}vendor/snapappointments/bootstrap-select/dist/css/bootstrap-select.min.css">

    <!-- 3d footprint viewer -->
    {if isset($foot3d_active) && $foot3d_active}
        <script src="{$relative_path}js/x3dom.js" async></script>
        <link rel="stylesheet" href="{$relative_path}css/x3dom.css">
    {/if}

    <!-- JQuery Tristate -->
    <!-- This must be in head because we need its functions in <script> Tags, in smarty_permission.tpl -->
    <script src="{$relative_path}js/jquery.tristate.min.js"></script>

    <!-- Javascript cookies -->
    <!-- We need this in header, because we use the library in show_part_label.php template -->
    <script src="{$relative_path}js/js.cookie-2.2.0.min.js"></script>

    {*
    {if isset($javascript_files)}
    {foreach $javascript_files as $file}
        <script type="text/javascript" src="{$relative_path}javascript/{$file.filename}.js" async></script>
    {/foreach}
    {/if} *}

    <!-- PHP Debugbar -->
    {if isset($debugbar_head)}{$debugbar_head nofilter}{/if}



    <!-- SCEditor (WYSIWYG BBCode Editor) -->
    <!-- <link rel="stylesheet" href="{$relative_path}js/sceditor/themes/default.min.css" />
        <script src="{$relative_path}js/sceditor/jquery.sceditor.bbcode.min.js" async></script> -->



</head>

<body>

    <header>

        <nav class="navbar navbar-expand-md navbar-light bg-light border-bottom shadow-sm fixed-top py-0" id="navbar">

            <button type="button" class="navbar-toggler" data-toggle="collapse" data-target="#sidebar-container">
                        <span class="sr-only">{t}Toggle Sidebar{/t}</span>
                        <!-- <span class="navbar-toggler-icon"></span> -->
                        <i class="fas fa-folder-open fa-lg fa-fw"></i>
            </button>

            <a class="navbar-brand" href="{$relative_path}startup.php"><i class="fa fa-microchip" aria-hidden="true"></i> {if !empty($partdb_title)}{$partdb_title}{else}Part-DB{/if}</a>

            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <!-- <span class="navbar-toggler-icon"></span> -->
                        <i class="fas fa-bars  fa-lg"></i>
            </button>



            <div class="collapse navbar-collapse" id="navbarContent">
                <div class="form-inline my-2 my-lg-0 ml-auto" id="searchbar">
                {*
                    <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search">
                    <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button> *}

                    {if isset($can_search) && $can_search}
                        <!-- Searchbar -->
                        <form action="{$relative_path}show_search_parts.php" method="get">
                    <div class="dropdown d-inline">
                            <button class="btn btn-light dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                                {t}Suchoptionen{/t}
                                <span class="caret"></span>
                            </button>
                            <div class="dropdown-menu" aria-labelledby="SearchOptions">
                                <div class="abc-checkbox form-check-dropdown"><input type="checkbox" class="form-check-input" name="search_name" value="true" checked>
                                    <label for="search_name" class="form-check-label">{t}Name{/t}</label></div>
                                <div class="abc-checkbox form-check-dropdown"><input type="checkbox" class="form-check-input" name="search_category" value="true" checked>
                                    <label for="search_category" class="form-check-label">{t}Kategorie{/t}</label></div>
                                <div class="abc-checkbox form-check-dropdown"><input type="checkbox" class="form-check-input" name="search_description" value="true" checked>
                                    <label for="search_description" class="form-check-label"></label>{t}Beschreibung{/t}</div>
                                <div class="abc-checkbox form-check-dropdown"><input type="checkbox" class="form-check-input" name="search_storelocation" value="true" checked>
                                    <label for="search_storelocation" class="form-check-label">{t}Lagerort{/t}</label></div>
                                <div class="form-check-dropdown abc-checkbox" class="form-check-label"><input type="checkbox" class="form-check-input" name="search_comment" value="true" checked>
                                    <label for="search_comment" class="form-check-label">{t}Kommentar{/t}</label></div>
                                {if !$suppliers_disabled}
                                    <div class="form-check-dropdown abc-checkbox"><input type="checkbox" class="form-check-input" name="search_supplierpartnr" value="true" checked>
                                        <label for="search_supplierpartnr" class="form-check-label">{t}Bestellnr.{/t}</label></div>
                                    <li class="form-check-dropdown abc-checkbox"><input type="checkbox" class="form-check-input" name="search_supplier" value="true">
                                        <label for="search_supplier" class="form-check-label">{t}Lieferant{/t}</label></li> {/if}
                                {if !$manufacturers_disabled}
                                    <div class="form-check-dropdown abc-checkbox"><input type="checkbox"  class="form-check-input" name="search_manufacturer" value="true">
                                    <label for="search_manufacturer" class="form-check-label">{t}Hersteller{/t}</label></div>
                                    <div class="form-check-dropdown abc-checkbox"><input type="checkbox"  class="form-check-input" name="search_manufacturer_code" value="true">
                                    <label for="search_manufacturer_code" class="form-check-label">{t}Herstellernummer{/t}</label></div>{/if}
                                <div class="form-check-dropdown abc-checkbox" class="form-check-label"><input type="checkbox" class="form-check-input" name="search_ean_code" value="true" checked>
                                    <label for="search_ean_code" class="form-check-label">{t}EAN Nummer{/t}</label></div>
                                {if !$footprints_disabled}
                                    <div class="form-check-dropdown abc-checkbox"><input type="checkbox" class="form-check-input" name="search_footprint" value="true">
                                    <label for="search_footprint" class="form-check-label">{t}Footprint{/t}</label></div>{/if}
                                <div class="form-check-dropdown abc-checkbox"><input type="checkbox" class="form-check-input" name="disable_pid_input" value="false">
                                    <label for="disable_pid_input" class="form-check-label">{t}Deakt. Barcode{/t}</label></div>
                                <div class="form-check-dropdown abc-checkbox"><input type="checkbox" class="form-check-input" name="regex" value="true">
                                    <label for="regex" class="form-check-label">{t}RegEx Matching{/t}</label></div>
                            </div>
                            </div>
                        <input type="search" class="form-control mr-sm-2" placeholder="{t}Suche{/t}" name="keyword"
                               {if $livesearch_active}onkeyup="livesearch(event, this, 2);"{/if}>
                        <button type="submit" id="search-submit" class="btn btn-outline-secondary my-2">{t}Los!{/t}</button>
                    </form>
                    {/if}
                </div>

                <a class="d-block d-md-none  nav-link link-datasheet" style="color: black;"
                        href="zxing://scan/?ret={if isset($smarty.server.HTTPS)}https{else}http{/if}%3A%2F%2F{$smarty.server.HTTP_HOST|escape:'url'}{$relative_path|escape:'url'}show_search_parts.php%3Fkeyword%3D%7BCODE%7D&SCAN_FORMATS=EAN_8,CODE_39">
                        <i class="fa fa-barcode fa-fw fa-lg" aria-hidden="true"></i>
                        <span class="ml-2 text-muted">{t}Scanne Barcode{/t}</span>
                    </a>

                <ul class="navbar-nav ml-3">
                    <li class="nav-item dropdown">
                        <a href="#" class="dropdown-toggle link-anchor nav-link" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        {if $loggedin}<i class="fa fa-user" aria-hidden="true"></i>{else}<i class="far fa-user" aria-hidden="true"></i>{/if} <span class="caret"></span></a>
                    <ul class="dropdown-menu dropdown-menu-right" id="login-menu">
                        {if $loggedin}
                            <a class="dropdown-item disabled" href="#" >{t}Eingeloggt als{/t} {$firstname} {$lastname} ({$username})</a>
                            <a class="dropdown-item" href="user_settings.php"><i class="fa fa-cogs fa-fw" aria-hidden="true"></i> {t}Benutzereinstellungen{/t}</a>
                            <a class="dropdown-item" href="user_info.php"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i> {t}Benutzerinformationen{/t}</a>
                            <li role="separator" class="dropdown-divider"></li>
                            <a class="dropdown-item"  href="{$relative_path}login.php?logout"><i class="fa fa-sign-out-alt fa-fw" aria-hidden="true"></i> {t}Logout{/t}</a>
                        {else}
                            <a class="dropdown-item" href="{$relative_path}login.php?redirect={$smarty.server.REQUEST_URI|escape:"url"}" id="login-link"><i class="fa fa-sign-in-alt fa-fw" aria-hidden="true"></i> {t}Login{/t}</a>
                        {/if}
                    </ul>
                    </li>
                </ul>
            </div>
          </nav>


        {*
        <nav class="navbar navbar-default navbar-fixed-top fh-fixedHeader" id="main-navbar">
            <div class="container-fluid">
             <!-- Brand and toggle get grouped for better mobile display -->
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#sidebar">
                        <span class="sr-only">{t}Toggle Sidebar{/t}</span>
                        <span class="fa fa-bars"></span>
                    </button>
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#searchbar" aria-expanded="false">
                        <span class="sr-only">{t}Toggle Navigation{/t}</span>
                        <span class="fa fa-search"></span>
                    </button>
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#userbar" aria-expanded="false">
                        <span class="sr-only">{t}Toggle Navigation{/t}</span>
                        <span class="fa fa-user"></span>
                    </button>
                    <a class="navbar-toggle link-datasheet" style="color: black;"
                        href="zxing://scan/?ret={if isset($smarty.server.HTTPS)}https{else}http{/if}%3A%2F%2F{$smarty.server.HTTP_HOST|escape:'url'}{$relative_path|escape:'url'}show_search_parts.php%3Fkeyword%3D%7BCODE%7D&SCAN_FORMATS=EAN_8,CODE_39">
                        <i class="fa fa-barcode" aria-hidden="true"></i>
                        <span class="sr-only">{t}Scanne Barcode{/t}</span>
                    </a>
                    <a class="navbar-brand" href="{$relative_path}startup.php"><i class="fa fa-microchip" aria-hidden="true"></i> {if !empty($partdb_title)}{$partdb_title}{else}Part-DB{/if}</a>
                </div>

            <ul class="nav collapse navbar-collapse navbar-nav navbar-right" id="userbar">
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle link-anchor" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        {if $loggedin}<i class="fa fa-user" aria-hidden="true"></i>{else}<i class="far fa-user" aria-hidden="true"></i>{/if} <span class="caret"></span></a>
                    <ul class="dropdown-menu" id="login-menu">
                        {if $loggedin}
                            <li class="disabled"><a href="#" >{t}Eingeloggt als{/t} {$firstname} {$lastname} ({$username})</a></li>
                            <li><a href="user_settings.php"><i class="fa fa-cogs fa-fw" aria-hidden="true"></i> {t}Benutzereinstellungen{/t}</a></li>
                            <li><a href="user_info.php"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i> {t}Benutzerinformationen{/t}</a></li>
                            <li role="separator" class="dropdown-divider"></li>
                            <li><a href="{$relative_path}login.php?logout"><i class="fa fa-sign-out-alt fa-fw" aria-hidden="true"></i> {t}Logout{/t}</a></li>
                        {else}
                            <li><a href="{$relative_path}login.php?redirect={$smarty.server.REQUEST_URI|escape:"url"}" id="login-link"><i class="fa fa-sign-in-alt fa-fw" aria-hidden="true"></i> {t}Login{/t}</a></li>
                        {/if}
                    </ul>
                </li>
            </ul>


            <noscript>
                <p class="navbar-text navbar-right" style="margin-right: 10px;">
                    {if $loggedin}
                        {t}Eingeloggt als{/t} <a href="{$relative_path}user_settings.php" class="navbar-link">{$firstname} {$lastname} ({$username})</a>
                        <a href="{$relative_path}login.php?logout" class="navbar-link">{t}Logout{/t}</a>
                    {else}
                        <a href="{$relative_path}login.php" class="navbar-link">{t}Login{/t}</a>
                    {/if}</p>
            </noscript>


            <!-- Navbar -->
            <div class="collapse navbar-collapse navbar-right" id="searchbar">

                {if isset($can_search) && $can_search}
                    <!-- Searchbar -->
                    <form class="navbar-form" action="{$relative_path}show_search_parts.php" method="get">
                        <div class="btn-group">
                            <button class="btn btn-default dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                                {t}Suchoptionen{/t}
                                <span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu" aria-labelledby="SearchOptions">
                                <li class="checkbox"><input type="checkbox" name="search_name" value="true" checked>
                                    <label for="search_name">{t}Name{/t}</label></li>
                                <li class="checkbox"><input type="checkbox" class="styled" name="search_category" value="true" checked>
                                    <label for="search_category">{t}Kategorie{/t}</label></li>
                                <li class="checkbox"><input type="checkbox" name="search_description" value="true" checked>
                                    <label for="search_description"></label>{t}Beschreibung{/t}</li>
                                <li class="checkbox"><input type="checkbox" name="search_storelocation" value="true" checked>
                                    <label for="search_storelocation">{t}Lagerort{/t}</label></li>
                                <li class="checkbox"><input type="checkbox" name="search_comment" value="true" checked>
                                    <label for="search_comment">{t}Kommentar{/t}</label></li>
                                {if !$suppliers_disabled}
                                    <li class="checkbox"><input type="checkbox" name="search_supplierpartnr" value="true" checked>
                                        <label for="search_supplierpartnr">{t}Bestellnr.{/t}</label></li>
                                    <li class="checkbox"><input type="checkbox" name="search_supplier" value="true">
                                        <label for="search_supplier">{t}Lieferant{/t}</label></li> {/if}
                                {if !$manufacturers_disabled}
                                    <li class="checkbox"><input type="checkbox" name="search_manufacturer" value="true">
                                    <label for="search_manufacturer">{t}Hersteller{/t}</label></li>{/if}
                                {if !$footprints_disabled}
                                    <li class="checkbox"><input type="checkbox" name="search_footprint" value="true">
                                    <label for="search_footprint">{t}Footprint{/t}</label></li>{/if}
                                <li class="checkbox"><input type="checkbox" name="disable_pid_input" value="false">
                                    <label for="disable_pid_input">{t}Deakt. Barcode{/t}</label></li>
                                <li class="checkbox"><input type="checkbox" name="regex" value="true">
                                    <label for="regex">{t}RegEx Matching{/t}</label></li>
                            </ul>
                        </div>

                        <input type="search" class="form-control" placeholder="{t}Suche{/t}" name="keyword"
                               {if $livesearch_active}onkeyup="livesearch(event, this, 2);"{/if}>
                        <button type="submit" id="search-submit" class="btn btn-default">{t}Los!{/t}</button>
                    </form>
                {/if}
            </div><!-- /.navbar-collapse -->
        </div><!-- /.container-fluid -->
    </nav>
    *}
</header>

<main>
    <div class="container-fluid">

        <div class="row">
                <div class="collapse d-md-block bg-light" id="sidebar-container">
                    <nav  {* class="fixed-sidebar"  *} class="fixed-sidebar col-md-3 col-lg-2 " id="fixed-sidebar">
                        <ul class="nav flex-column">
                            {if isset($can_category) && $can_category}
                                <li id="categories">
                                    <!-- <h4>{t}Kategorien{/t}</h4>-->
                                    <div class="dropdown">
                                        <button class="btn-text dropdown-toggle mb-2" type="button" id="dropdownCat" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                                           <span class="sidebar-title" id="tree-categories-title">{t}Kategorien{/t}</span>
                                        </button>
                                        <ul class="dropdown-menu" aria-labelledby="dropdownCat">
                                            <li class="dropdown-header">{t}Aktionen{/t}</li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="expand" data-target="tree-categories">{t}Alle ausklappen{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="collapse" data-target="tree-categories">{t}Alle einklappen{/t}</a></li>
                                            <li role="separator" class="dropdown-divider"></li>
                                            <li class="dropdown-header">{t}Datenquelle{/t}</li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="categories" data-target="tree-categories">{t}Kategorien{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="locations" data-target="tree-categories">{t}Lagerorte{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="footprints" data-target="tree-categories">{t}Footprints{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="manufacturers" data-target="tree-categories">{t}Hersteller{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="suppliers" data-target="tree-categories">{t}Lieferanten{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="devices" data-target="tree-categories">{t}Baugruppen{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="tools" data-target="tree-categories">{t}Verwaltung{/t}</a></li>
                                        </ul>
                                    </div>
                                    <div id="tree-categories"></div>
                                </li>
                            {/if}
                            {if !$devices_disabled && isset($can_device) && $can_device}
                                <li id="devices">
                                    <div class="dropdown">
                                        <button class="btn-text dropdown-toggle mb-2 mt-2" type="button" id="dropdownDev" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                                            <span class="sidebar-title" id="tree-devices-title">{t}Baugruppen{/t}</span>
                                        </button>
                                        <ul class="dropdown-menu" aria-labelledby="dropdownDev">
                                            <li class="dropdown-header">{t}Aktionen{/t}</li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="expand" data-target="tree-devices">{t}Alle ausklappen{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="collapse" data-target="tree-devices">{t}Alle einklappen{/t}</a></li>
                                            <li role="separator" class="dropdown-divider"></li>
                                            <li class="dropdown-header">{t}Datenquelle{/t}</li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="categories" data-target="tree-devices">{t}Kategorien{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="locations" data-target="tree-devices">{t}Lagerorte{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="footprints" data-target="tree-devices">{t}Footprints{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="manufacturers" data-target="tree-devices">{t}Hersteller{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="suppliers" data-target="tree-devices">{t}Lieferanten{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="devices" data-target="tree-devices">{t}Baugruppen{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="tools" data-target="tree-devices">{t}Verwaltung{/t}</a></li>
                                        </ul>
                                    </div>
                                    <div id="tree-devices"></div>
                                </li>
                            {/if}

                            <li id="tools">
                                <div class="dropdown">
                                    <button class="btn-text dropdown-toggle mb-2 mt-2" type="button" id="dropdownTools" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                                        <span class="sidebar-title" id="tree-tools-title">{t}Verwaltung{/t}</span>
                                    </button>
                                    <ul class="dropdown-menu" aria-labelledby="dropdownTools">
                                        <li class="dropdown-header">{t}Aktionen{/t}</li>
                                        <li><a href="#" class="tree-btns dropdown-item" data-mode="expand" data-target="tree-tools">{t}Alle ausklappen{/t}</a></li>
                                        <li><a href="#" class="tree-btns dropdown-item" data-mode="collapse" data-target="tree-tools">{t}Alle einklappen{/t}</a></li>
                                        <li role="separator" class="dropdown-divider"></li>
                                           <li class="dropdown-header">{t}Datenquelle{/t}</li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="categories" data-target="tree-tools">{t}Kategorien{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="locations" data-target="tree-tools">{t}Lagerorte{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="footprints" data-target="tree-tools">{t}Footprints{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="manufacturers" data-target="tree-tools">{t}Hersteller{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="suppliers" data-target="tree-tools">{t}Lieferanten{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="devices" data-target="tree-tools">{t}Baugruppen{/t}</a></li>
                                            <li><a href="#" class="tree-btns dropdown-item" data-mode="tools" data-target="tree-tools">{t}Verwaltung{/t}</a></li>
                                    </ul>
                                </div>
                                <div id="tree-tools"></div>
                            </li>
                        </ul>


                    <noscript><b>{t}Bitte aktivieren sie Javascript, um alle Funktionen benutzen zu können.{/t}</b></noscript>

                </nav>
                </div>

            <div class="col-md-9 col-lg-10 offset-md-3 offset-lg-2 pl-0" id="main">
                <div class="container-fluid mr-0 pr-0" id="content">

                    {else} {* Print tile in ajax requests, or we cant set the tab title *}
                    <title>{$page_title}</title>

                    {/if}


                    <div id="content-data">

                        {if isset($messages)}
                        {assign "alert_style" "alert-info"}
                        {assign "alert_icon" "fas fa-info"}
                        {foreach $messages as $msg}
                            {if isset($msg.color) && $msg.color == "red"}
                                {assign "alert_style" "alert-danger"}
                                {assign "alert_icon" "fas fa-exclamation"}
                            {elseif isset($msg.color) && ( $msg.color == "green" || $msg.color == "darkgreen")}
                                {assign "alert_style" "alert-success"}
                                {assign "alert_icon" "fas fa-check"}
                            {elseif isset($msg.color) && ($msg.color == "yellow" || $msg.color == "orange")}
                                {assign "alert_style" "alert-warning"}
                                {assign "alert_icon" "fas fa-bell"}
                            {/if}
                        {/foreach}
                        <div class="alert {$alert_style}" id="messages">
                                <div class="row vertical-align">
                                    <div class="col-md-1">
                                        <i class="{$alert_icon} fa-5x" style="text-align: center; width: 1em;"></i>
                                    </div>
                                    <div class="col-md-11">
                                        <div>
                                            {if !empty($messages_div_title)}<h4>{$messages_div_title}</h4>{/if}
                                            <form action="" method="post" class="no-progbar">
                                            {foreach $messages as $msg}
                                                {if isset($msg.text)}
                                                    {if isset($msg.strong) && $msg.strong}<strong>{/if}
                                                    {$msg.text nofilter}
                                                    {if isset($msg.strong) && $msg.strong}</strong>{/if}
                                                {/if}

                                                {if isset($msg.html)}
                                                    {$msg.html nofilter}
                                                {/if}

                                                {if !isset($msg.no_linebreak) || !$msg.no_linebreak}<br>{/if}
                                            {/foreach}

                                            {if !empty($reload_link)}
                                                <a href="{$reload_link}">
                                                    <br>
                                                    <button class="btn btn-secondary">{t}Seite neu laden{/t}</button>
                                                </a>
                                            {/if}
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
{/if}