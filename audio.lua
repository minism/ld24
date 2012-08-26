-- local audio = {
--     source_tables = {},
-- }

-- local VOICES = 4
-- local SourceTable = leaf.Object:extend()
-- function SourceTable:init(path)
--     self.counter = 1
--     self.voices = {}
--     self.nvoices = VOICES
--     if path:find("gun") then
--         self.nvoices = self.nvoices * 4
--     end
--     for i=1, self.nvoices do
--         self.voices[i] = love.audio.newSource(path)
--     end
-- end

-- function SourceTable:play()
--     local source = self.voices[self.counter]
--     source:play()
--     self.counter = (self.counter % self.nvoices) + 1
-- end

-- function audio.load()
--     audio.source_tables = leaf.fs.recursiveYieldingLoader('sfx', audio.register)
-- end

-- function audio.register(path)
--     local source_table = SourceTable(path)
--     return source_table
-- end

-- function audio.play(name)
--     local source_table = audio.source_tables[name]
--     if source_table then
--         source_table:play()
--     end
-- end

-- return audio

return {
    play = function(name)
        assets.sfx[name]:play()
    end,
}

