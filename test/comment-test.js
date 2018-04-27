var fs = require('fs')
var comment = require('../comment')

describe('comment', function() {

  let release

  it('release', function() {
    return comment.release('unitTest')
    .then(function(_release) {
      release = _release;
      release.should.have.property('id');
    })
  })

  it('addCommentVersionToDoc', function() {
    var content = fs.readFileSync(__dirname + '/comment-example.html', {encoding: 'utf-8'});
    console.log('before:', content);
    return comment.addCommentIdToDoc('unitTest.html', content, release)
    .then(function(newContent) {
      console.log('after', newContent)
    })
  })

  //it('test', function() {
  //  this.timeout(30000)
  //  var content = fs.readFileSync(__dirname + '/../dist/rest_api.html', {encoding: 'utf-8'});
  //  return comment.addCommentIdToDoc('unitTest.html', content, '595b553dac502e006b8e2858')
  //})

})
