describe 'DS.ElasticSearchAdapter', ->
  beforeEach ->
    @subject = new TestEnv()

  describe "find", ->
    it "by id", ->
      @subject.loadData()
      runs ->
        model =  window.Fixture.store.find('user', 2)
        waitsFor ->
          model.get('name') != null && model.get('name') != undefined

        runs ->
          expect(model.get('name')).toEqual('bar2')

    it "by query", ->
      @subject.loadData()
      json = QueryDSL.query ->
        @match {job: {query: "bar"}}
      runs ->
        model =  window.Fixture.store.find('user', json)
        waitsFor ->
          model.toArray().length == 3
        runs ->

          expect(model.toArray().length).toEqual(3)

    it 'get total', ->
      model = undefined
      @subject.loadData()
      json = QueryDSL.query ->
        @match {job: {query: "bar"}}
      runs ->
        window.Fixture.store.find('user', json).then (_model) ->
          model = _model
        waitsFor ->
          model != undefined && model.toArray().length == 3
        runs ->
          expect(model.total).toEqual(3)

  describe 'create, update, delete', ->
    it "create document", ->
      runs ->
        model = window.Fixture.store.createRecord('user', {name: "my name"})
        model.save()
        waitsFor ->
          model.get('id') != undefined && model.get('id') != null
        runs ->
          expect(model.get('id')).toBeDefined()
          expect(model.get('name')).toEqual('my name')

    it 'update document', ->
      @subject.loadData()
      model = undefined
      runs ->
        window.Fixture.store.find('user', 2).then (_model) ->
          model = _model
        waitsFor ->
          model != undefined  && model.get('name') != null && model.get('name') != undefined

        runs ->
          model.set('name', "updated")
          model.save()
          expect(model.get('name')).toEqual('updated')

    it 'delete document', ->
      @subject.loadData()
      model = undefined
      runs ->
        window.Fixture.store.find('user', 2).then (_model) ->
          model = _model
        waitsFor ->
          model != undefined  && model.get('name') != null && model.get('name') != undefined

        runs ->
          model.deleteRecord()
          model.save()
          expect(model.get('isDeleted')).toBe(true)