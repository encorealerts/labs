$(function () {

  var 
    $blocker = $('#blocker'),
    blocked = true,
    activities = [];

  window.Blocker = {
    block: function (){
      $blocker.show();
      blocked = true;
    },
    release: function () {
      $blocker.hide();
      blocked = false;
    },
    get blocked(){
      return blocked;
    }
  };

  function requestActivities(source, limit, polyArg) {
    var thisActivities, 
      callback = (typeof polyArg == 'function') ? polyArg : null, 
      async = (typeof polyArg == 'boolean') ? polyArg : true;

    if (!async) { Blocker.block(); }
    $.ajax({
      type: "GET",
      cache: false,
      url: '/trainers/activities', 
      data: {limit: limit, source: source}, 
      async: async,
      success: function (response) {
        if (!async) {
          thisActivities = response.activities;
        } else if (callback) {
          callback(response.activities);
        }
      }
    });
    if (!async) { Blocker.release(); }
    return thisActivities;
  }

  window.Requester = {
    getActivity: function (source, limit) {
      var newRequestThreshold = (limit / 10) * 2;

      if (activities.length === 0) {
        activities = activities.concat(requestActivities(source, limit, false));
      }

      if (activities.length <= newRequestThreshold){
        requestActivities(source, limit, function (_activities) {
          activities = activities.concat(_activities);
        });
      }
      return activities.splice(0,1)[0];
    },
    postAction: function (nativeId, source, action, callback) {
      Blocker.block();
      $.ajax({
        type: 'POST',
        url: '/trainers/save',
        dataType:'json',
        data: {
          nativeId: nativeId,
          action: action,
          source: source
        },
        success: function (data) {
          if (callback) { callback(data); }
          Blocker.release();
        }
      });
    }
  }

  Blocker.release();
});