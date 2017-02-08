$.urlParam = function (name) {
  var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
  if (results == null) { return ""; }
  return results[1] || "";
}

$(function() {
  $('.ui.dropdown').dropdown();
  $('.ui.rating').rating({
    interactive: false
  });

  $('#studio-filter').dropdown({
    forceSelection: false
  });

  $('#performer-filter').dropdown({
    forceSelection: false
  });

  $('#tag-filter').dropdown({
    forceSelection: false
  });

  $('#gallery-filter').dropdown({
    forceSelection: false,
    fullTextSearch: true
  });

  $('#clear-gallery-button').on('click', function() {
    $('#gallery-filter').dropdown('clear');
  });

  $('#scene-edit-rating').rating({
    interactive: true,
    onRate: function(value) {
      $('#scene_rating').val(value);
    }
  });

  var q = $.urlParam('q').replace(/\+/g, '%20');
  q = q.replace(/\+/g, '%20');
  q = decodeURIComponent(q);

  $('form')
  .form('set values', {
    q: q || '',
    sort: $.urlParam('sort') || 'path',
    direction: $.urlParam('direction') || 'asc',
    filter_studios: decodeURIComponent($.urlParam('filter_studios')).split(','),
    filter_performers: decodeURIComponent($.urlParam('filter_performers')).split(','),
    filter_tags: decodeURIComponent($.urlParam('filter_tags')).split(','),
    filter_rating: decodeURIComponent($.urlParam('filter_rating')),
    filter_missing: decodeURIComponent($.urlParam('filter_missing'))
  });
});
