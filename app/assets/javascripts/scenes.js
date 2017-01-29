$.urlParam = function (name) {
  var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
  if (results == null) { return ""; }
  return results[1] || "";
}

$(function() {
  $('.ui.dropdown').dropdown();

  $('#studio-filter').dropdown({
    apiSettings: {
      onResponse: function(res) {
        var response = { success: true, results: [] };
        $.each(res, function(index, item) {
          var name = item.name || 'Unknown', maxResults = 8;
          if (index >= maxResults) { return false; }

          response.results.push({
            name: item.name,
            value: item.id
          });
        });

        return response;
      },
      url: '/studios.json?q={query}'
    },
    forceSelection: false
  });

  $('#performer-filter').dropdown({
    apiSettings: {
      onResponse: function(res) {
        var response = { success: true, results: [] };
        $.each(res, function(index, item) {
          var name = item.name || 'Unknown', maxResults = 8;
          if (index >= maxResults) { return false; }

          response.results.push({
            name: item.name,
            value: item.id
          });
        });

        return response;
      },
      url: '/performers.json?q={query}'
    },
    forceSelection: false
  });

  // HACK: Fields don't populate automatically.  We click to force the API request so there is something to fill...
  $('#performer-filter').trigger('click');
  $('#studio-filter').trigger('click');
  $('#scene-search').focus();

  var q = $.urlParam('q').replace(/\+/g, '%20');
  q = q.replace(/\+/g, '%20');
  q = decodeURIComponent(q);

  $('form')
  .form('set values', {
    q: q || '',
    sort: $.urlParam('sort') || 'path',
    direction: $.urlParam('direction') || 'desc',
    filter_studios: decodeURIComponent($.urlParam('filter_studios')).split(','),
    filter_performers: decodeURIComponent($.urlParam('filter_performers')).split(',')
  });
});
