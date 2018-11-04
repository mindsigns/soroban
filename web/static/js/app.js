// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import { Sort } from "./sort"

export const App = {
  sortTable: Sort.makeSortable
}

$(function () {
      $('[data-toggle="tooltip"]').tooltip()
})

//require( 'jquery' );
require( 'jszip' );
//require( 'datatables.net-bs4' )();
require( 'datatables.net-buttons-bs4' )();
require( 'datatables.net-buttons/js/buttons.html5.js' )();
require( 'datatables.net-buttons/js/buttons.print.js' )();
require( 'datatables.net-responsive-bs4' )();

window.$ = window.jquery = require('jquery');
window.dt = require('datatables.net')();
window.dtbs4 = require('datatables.net-bs4')();
//window.$('#dataTable').DataTable();

// import socket from "./socket"

