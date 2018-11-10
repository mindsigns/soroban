//$(document).ready(function(){$("#dataTable").DataTable({responsive: true})});
$(document).ready(function() {
    $('#dataTableBasic').DataTable( {
                    dom: 'Bfrtip',
                    buttons: [
                    'csv', 'excel', 'print'
                    ]
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


