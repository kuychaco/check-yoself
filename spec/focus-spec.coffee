describe "focused tests", ->
  fffit "only runs focused tests with the highest focus level", ->
  it "doesn't run others", ->
  fffdescribe "nested tests", ->
    it "runs all tests nested within a focused describe", ->
    describe "deeper nesting", ->
      it "runs if parent describe has highest focus level", ->
  describe "when a nested it...", ->
    it "this is skipped"
    describe "... has highest focus level too", ->
      fffit "runs the focused it", ->
      it "doesn't run non focused it", ->
