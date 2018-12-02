<?php
/*
    part-db version 0.1
    Copyright (C) 2005 Christoph Lechner
    http://www.cl-projects.de/

    part-db version 0.2+
    Copyright (C) 2009 K. Jacobs and others (see authors.php)
    http://code.google.com/p/part-db/

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
*/

include_once('start_session.php');

use PartDB\Database;
use PartDB\HTML;
use PartDB\Log;
use PartDB\Part;
use PartDB\Permissions\PartPermission;
use PartDB\Permissions\PermissionManager;
use PartDB\User;

$messages = array();
$fatal_error = false; // if a fatal error occurs, only the $messages will be printed, but not the site content

$page               = isset($_REQUEST['page'])              ? (integer)$_REQUEST['page']            : 1;
$limit              = isset($_REQUEST['limit'])             ? (integer)$_REQUEST['limit']           : $config['table']['default_limit'];

/********************************************************************************
 *
 *   Initialize Objects
 *
 *********************************************************************************/

$html = new HTML($config['html']['theme'], $user_config['theme'], 'Teile ohne Preis');

try {
    $database           = new Database();
    $log                = new Log($database);
    $current_user       = User::getLoggedInUser($database, $log);

    $current_user->tryDo(PermissionManager::PARTS, PartPermission::NO_PRICE_PARTS);

    //Remember what page user visited, so user can return there, when he deletes a part.
    session_start();
    $_SESSION["part_delete_last_link"] = $_SERVER['REQUEST_URI'];
    session_write_close();
} catch (Exception $e) {
    $messages[] = array('text' => nl2br($e->getMessage()), 'strong' => true, 'color' => 'red');
    $fatal_error = true;
}

/********************************************************************************
 *
 *   Generate Table
 *
 *********************************************************************************/

if (! $fatal_error) {
    try {
        $parts = Part::getNoPriceParts($database, $current_user, $log, $limit, $page);
        $table_loop = Part::buildTemplateTableArray($parts, 'noprice_parts');
        $html->setVariable('table', $table_loop);
        $html->setVariable('table_rowcount', count($parts));

        $html->setVariable("pagination", generatePagination("show_noprice_parts.php?", $page, $limit, Part::getNoPricePartsCount($database, $current_user, $log)));
        $html->setVariable("page", $page);
        $html->setVariable('limit', $limit);
    } catch (Exception $e) {
        $messages[] = array('text' => nl2br($e->getMessage()), 'strong' => true, 'color' => 'red');
        $fatal_error = true;
    }
}

/********************************************************************************
 *
 *   Set the rest of the HTML variables
 *
 *********************************************************************************/


if (! $fatal_error) {
    // global stuff
    try {
        $html->setVariable('disable_footprints', $config['footprints']['disable'], 'boolean');
        $html->setVariable('disable_manufacturers', $config['manufacturers']['disable'], 'boolean');
        $html->setVariable('disable_auto_datasheets', $config['auto_datasheets']['disable'], 'boolean');
    } catch (Exception $e) {
        $messages[] = array('text' => nl2br($e->getMessage()), 'strong' => true, 'color' => 'red');
        $fatal_error = true;
    }
}

/********************************************************************************
 *
 *   Generate HTML Output
 *
 *********************************************************************************/


//If a ajax version is requested, say this the template engine.
if (isset($_REQUEST["ajax"])) {
    $html->setVariable("ajax_request", true);
}

$html->printHeader($messages);

if (! $fatal_error) {
    $html->printTemplate('show_noprice_parts');
}

$html->printFooter();
