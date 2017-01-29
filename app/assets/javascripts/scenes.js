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
});
