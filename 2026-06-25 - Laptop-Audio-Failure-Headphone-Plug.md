**2026-06-25 - Laptop-Audio-Failure-Headphone-Plug**

**AFTER-ACTION REPORT**

**1. Executive Summary**  
Laptop suddenly had no audio from the internal speakers or Bluetooth. After juggling ALSA, PipeWire, kernel modules, and various settings for nearly an hour, the root cause turned out to be a 3.5mm male-to-male audio cable plugged into the headphone jack.

**2. Timeline**  
- 00:00 – Noticed complete loss of audio output  
- 00:10 – Checked volume, playback devices, and restarted PipeWire  
- 00:25 – Ran `alsamixer`, `pactl list`, `inxi -A`, and tried different kernels  
- 00:45 – Started deep-diving configuration files  
- 00:52 – Physically checked the laptop and found a 3.5mm male-to-male lead plugged into the headphone socket  
- 00:53 – Removed the cable → audio immediately returned to normal  

**3. Root Cause**  
A 3.5mm male-to-male audio cable was left plugged into the headphone jack. The system was correctly detecting “headphones” and routing all audio output to the jack instead of the built-in speakers.

**4. What Went Wrong**  
- Jumped straight into software troubleshooting because “it worked fine yesterday”  
- Completely overlooked the most basic physical check

**5. Lessons Learned**  
- Always check the obvious physical things first (cables, plugs, power, etc.), no matter how technical the symptoms look.  
- Software and hardware problems can look almost identical.  
- “It worked yesterday” doesn’t rule out accidental user error.  
- Don’t overcomplicate things — sometimes the answer really is that simple (and embarrassing).

**6. Recommendations**  
- Add “Physically inspect all audio ports” as step 1 in any future audio troubleshooting checklist.
