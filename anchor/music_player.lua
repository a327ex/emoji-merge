local music_player = class:class_new()
function music_player:music_player_init()
  self.songs = {}
  self.current_loop_songs = {}
  self.play_sequence = {}
  self.play_index = 1
  self.play_volume = 1
  self.current_song = nil
  table.insert(main.music_player_objects, self)
  return self
end

function music_player:music_player_update(dt)
  if self.current_song and not self.current_song:isPlaying() then
    self.play_index = self.play_index + 1
    if self.play_index > #self.play_sequence then
      self.play_index = 1
      table.shuffle(self.play_sequence)
    end
    self.current_song = self.songs[self.play_sequence[self.play_index]]:sound_play(self.play_volume)
  end
end

-- Plays multiple songs infinitely.
-- If play_sequence is provided then it will play the songs in that sequence, otherwise it will play them on a random order such that no song is repeated before all others have been played at least once per loop.
-- The currently playing song will always be .current_song.
-- :music_player_play_songs({song1 = sound('assets/song1.ogg'), song2 = sound('assets/song2.ogg'), song3 = sound('assets/song3.ogg')}, {'song2', 'song3', 'song1'}) -> plays song2 then song3 then song1 then repeats this loop infinitely
function music_player:music_player_play_songs(songs, play_sequence, volume)
  self.songs = songs 
  self.play_sequence = play_sequence or {}
  self.play_index = 1
  if not play_sequence then
    for song_name, _ in pairs(self.songs) do table.insert(self.play_sequence, song_name) end
    table.shuffle(self.play_sequence)
  end
  self.play_volume = volume
  self.current_song = self.songs[self.play_sequence[self.play_index]]:sound_play(volume)
end

-- Stops playing all songs.
function music_player:music_player_stop()
  self.play_sequence = {}
  self.play_index = 1
  self.current_song:stop()
  self.current_song = nil
end

--[[
-- Switches to and plays a specific song.
-- When the song ends no other song will be played, but .song_ended will be true and you can manually switch to another song or start another infinite play (with music_player_play_songs).
-- :music_player_switch_to_song('song1')
function music_player:music_player_switch_to_song(song_name, volume, pitch)
  self.song_ended = false
  self.play_sequence = {}
  self.current_loop_songs = {}
  self.play_index = 1
  self.play_volume = volume
  self.current_song = self.songs[song_name]:sound_play(volume, pitch)
end
]]--

return music_player
