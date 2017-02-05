$.urlParam = function (name) {
  var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
  if (results == null) { return ""; }
  return results[1] || "";
}

$(function() {
  $('.ui.dropdown').dropdown();

  $('#studio-filter').dropdown({
    forceSelection: false
  });

  $('#performer-filter').dropdown({
    forceSelection: false
  });

  $('#tag-filter').dropdown({
    forceSelection: false
  });

  var q = $.urlParam('q').replace(/\+/g, '%20');
  q = q.replace(/\+/g, '%20');
  q = decodeURIComponent(q);

  $('form')
  .form('set values', {
    q: q || '',
    sort: $.urlParam('sort') || 'path',
    direction: $.urlParam('direction') || 'desc',
    filter_studios: decodeURIComponent($.urlParam('filter_studios')).split(','),
    filter_performers: decodeURIComponent($.urlParam('filter_performers')).split(','),
    filter_tags: decodeURIComponent($.urlParam('filter_tags')).split(',')
  });
});
