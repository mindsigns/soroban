//$(document).ready(function(){$("#dataTable").DataTable({responsive: true})});
$(document).ready(function() {
    $('#dataTableSort').DataTable( {
                    dom: 'rt',
                    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]],
                    responsive: false
                } );
} );

$(document).ready(function() {
    $('#dataTableBasic').DataTable( {
                    dom: 'lfrtip',
                    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]],
                    responsive: false
                } );
} );

$(document).ready(function() {
    $('#dataTable').DataTable( {
                    dom: 'Bfrltip',
                    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]],
                    initComplete: function () {
                        var api = this.api();
                        api.$('td').click( function () {
                        api.search( this.innerHTML ).draw();
                    } ); },
		            deferRender: true,
                    buttons: [ 'csv', 'excel', 'print' ]
                    } );
} );


