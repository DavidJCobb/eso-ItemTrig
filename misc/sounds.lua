local SoundManager = {
   playing = {},
   waitingForUpdate = false,
}
ItemTrig.SoundManager = SoundManager

--
-- Singleton to only allow a sound to be queued to play once per 
-- frame. The PlaySound API doesn't have this behavior built-in; 
-- if you queue a sound to play 50 times in one frame, it will 
-- play fifty times concurrently (i.e. 50 times as loud as normal).
--

do
   local MAX_SOUND_GAP = 100
   --
   local function _update()
      SoundManager.waitingForUpdate = false
      SoundManager.playing = {}
   end
   function SoundManager:_registerForUpdate()
      if self.waitingForUpdate then
         return
      end
      self.waitingForUpdate = true
      zo_callLater(_update, MAX_SOUND_GAP)
   end
end
function SoundManager:play(id) -- e.g. SoundManager:play(SOUNDS.WHATEVER)
   if self.playing[id] then
      return
   end
   if (not id) or id == "" then
      return
   end
   self.playing[id] = true
   PlaySound(id)
   self:_registerForUpdate()
end