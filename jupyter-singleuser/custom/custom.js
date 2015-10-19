function top_level_mods() {
  var img = $('#header-container').find('img[alt="Jupyter Notebook"]').attr('id', 'logo');
  img.attr('src', img.attr('src').replace('static/base/images', 'custom'));
  $('body').append('<div id="footer" />');
}

$([IPython.events]).on('app_initialized.DashboardApp', function() {
  top_level_mods();
  $('div#ipython-main-app').prepend('<div id="notice" >');
  $('#notice').html('This is a proof-of-concept demonstration server. For more information see <a href="https://www.unidata.ucar.edu/projects/index.html#python">here</a>.');
});

$([IPython.events]).on('app_initialized.NotebookApp', function() {
  top_level_mods();
});
