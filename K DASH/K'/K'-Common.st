; Common state file for M.U.G.E.N 1.0
;
; System variables usage
; ----------------------
; Var name    Type   Purpose
; --------    ----   -------
; sysvar(0)   Temp   Set by state 5081 (HITL_SLIDE) to 1 to prevent
;                    showing ground hit frame in state 5110 (HIT_LIEDOWN).
;                    Used by guarding states.
; sysvar(1)   Temp   Used by state 40 (Jump Start) amd 45 (Air Jump Start)
;                    to keep track of which way to jump.
;                    Used by state 5100 and 5110 to remember downward
;                    velocity of player just before hitting the ground.
;                    Used in state 5080 for storing the anim # to display.

; The following states have special handling within MUGEN, and should be
; overridden with caution:
; Jump Start (40): airjumping bookkeeping at time = 0
; All guard states (120-155): guard handling throughout state
; Hit_trip, shaking (5070): defense increases at time = 0
; Downed get-hit (hit ground from fall) (5100):
;   defense increases at time = 0, player becomes invincible if within 10
;   ticks of getting up
; Hit_liedown (5110): player changes to get-up state (5120) when ready
; Hit_getup (5120): players defence is restored to normal at time = 0
; Hitfall_recover (5200): players defence is restored at time = 0
; Hitfall_airrecover (5210): players defence is restored at time = 0

;---------------------------------------------------------------------------
; Stand
[Statedef 0]
type = S
physics = S
sprpriority = 0

[State 0, 1]
type = ChangeAnim
trigger1 = Anim != 0 && Anim != 5
trigger2 = Anim = 5 && AnimTime = 0 ;Turn anim over
value = 0

[State 0, 2]
type = VelSet
trigger1 = Time = 0
y = 0

[State 0, 3] ;Stop moving if low velocity or 4 ticks pass
type = VelSet
trigger1 = abs(vel x) < Const(movement.stand.friction.threshold)
trigger2 = Time = 4
x = 0

[State 0, 4] ;Are you dead?
type = ChangeState
trigger1 = !alive
value = 5050
ctrl = 0

[State 0, 5] ;Are you floating?
type = ChangeState
trigger1 = pos y < 0
value = 50

;---------------------------------------------------------------------------
; Stand to Crouch
[Statedef 10]
type    = C
physics = C
anim = 10

[State 10, 1]
type = VelMul
trigger1 = Time = 0
x = .75

[State 10, 2] ;Stop moving if low velocity
type = VelSet
trigger1 = abs(vel x) < Const(movement.crouch.friction.threshold)
x = 0

[State 10, 3]
type = ChangeState
trigger1 = AnimTime = 0
value = 11

;---------------------------------------------------------------------------
; Crouching
[Statedef 11]
type    = C
physics = C
anim = 11
sprpriority = 0

[State 11, 1] ;Change from turning animation
type = ChangeAnim
trigger1 = Anim = 6 && AnimTime = 0
value = 11

[State 11, 2] ;Stop moving if low velocity
type = VelSet
trigger1 = abs(vel x) < Const(movement.crouch.friction.threshold)
x = 0

;---------------------------------------------------------------------------
; Crouch to Stand
[Statedef 12]
type    = S
physics = S
anim = 12

[State 12, 1]
type = ChangeState
trigger1 = AnimTime = 0
value = 0

;---------------------------------------------------------------------------
; Walk
[Statedef 20]
type    = S
physics = S
sprpriority = 0

[State 20, 1]
type = VelSet
trigger1 = command = "holdfwd"
x = const(velocity.walk.fwd.x)

[State 20, 2]
type = VelSet
trigger1 = command = "holdback"
x = const(velocity.walk.back.x)

[State 20, 3]
type = ChangeAnim
triggerall = vel x > 0
trigger1 = Anim != 20 && Anim != 5
trigger2 = Anim = 5 && AnimTime = 0
value = 20

[State 20, 4]
type = ChangeAnim
triggerall = vel x < 0
trigger1 = Anim != 21 && Anim != 5
trigger2 = Anim = 5 && AnimTime = 0
value = 21

;---------------------------------------------------------------------------
; Jump Start
[Statedef 40]
type    = S
physics = S
anim = 40
ctrl = 0
sprpriority = 1

[State 40]
type = changeState
trigger1 = time = 0
trigger1 = var(59)
value = 0
ctrl = 1

[State 40, 1]
type = VarSet
trigger1 = Time = 0
sysvar(1) = 0

[State 40, 2]
type = VarSet
trigger1 = command = "holdfwd"
sysvar(1) = 1

[State 40, 3]
type = VarSet
trigger1 = command = "holdback"
sysvar(1) = -1

[State 40, 4]
type = VelSet
trigger1 = AnimTime = 0
x = ifelse(sysvar(1)=0, const(velocity.jump.neu.x), ifelse(sysvar(1)=1, const(velocity.jump.fwd.x), const(velocity.jump.back.x)))
y = const(velocity.jump.y)

[State 40, 5]
type = VelSet
trigger1 = AnimTime = 0
trigger1 = prevstateno = 100 ;RUN_FWD
trigger1 = sysvar(1) = 1
x = const(velocity.runjump.fwd.x)

[State 40, 6]
type = ChangeState
trigger1 = AnimTime = 0
value = 50
ctrl = 1

;---------------------------------------------------------------------------
; AirJump Start
[Statedef 45]
type    = A
physics = N
ctrl = 0
velset = 0,0

[State 45, 1]
type = ChangeAnim
trigger1 = SelfAnimExist(44)
value = 44

[State 45, 2]
type = ChangeAnim
trigger1 = !SelfAnimExist(44)
value = 41

[State 45, 3]
type = VarSet
trigger1 = Time = 0
sysvar(1) = 0

[State 45, 4]
type = VarSet
trigger1 = command = "holdfwd"
sysvar(1) = 1

[State 45, 5]
type = VarSet
trigger1 = command = "holdback"
sysvar(1) = -1

[State 45, 6]
type = VelSet
trigger1 = Time = 2
x = ifelse(sysvar(1)=0, const(velocity.airjump.neu.x), ifelse(sysvar(1)=1, const(velocity.airjump.fwd.x), const(velocity.airjump.back.x)))
y = const(velocity.airjump.y)

[State 45, 7]
type = ChangeState
trigger1 = Time = 2
value = 50
ctrl = 1

;---------------------------------------------------------------------------
; Jump Up
[Statedef 50]
type    = A
physics = A

[State 100, 3] ;Prevent from turning
type = AssertSpecial
trigger1 = 1
flag = NoAutoTurn

[State 50, 1]
type = VarSet
trigger1 = Time = 0
sysvar(1) = 0

[State 50, 2]
type = ChangeAnim
trigger1 = Time = 0
value = ifelse((vel x)=0, 41, ifelse((vel x)>0, 42, 43))

[State 50, 3]
type = ChangeAnim
trigger1 = Vel y > Const720p(-8)
trigger1 = SelfAnimExist(anim + 3)
trigger1 = anim >= 41 && anim <= 43
persistent = 0
value = Anim + 3

;---------------------------------------------------------------------------
; Jump Down (empty state for compatibility)
[Statedef 51]
type    = A
physics = A

[State 51, 1]
type = Null
trigger1 = 1

;---------------------------------------------------------------------------
; Jump Land
[Statedef 52]
type    = S
physics = S
ctrl = 0
anim = 47

[State 52, 1]
type = VelSet
trigger1 = Time = 0
y = 0

[State 52, 2]
type = PosSet
trigger1 = Time = 0
y = 0

[State 52, 3]
type = CtrlSet
trigger1 = Time = 3
value = 1

[State 52, 4]
type = VelSet
trigger1 = abs(vel x) < Const(movement.stand.friction.threshold)
x = 0

[State 52, 5]
type = ChangeState
trigger1 = AnimTime = 0
value = 0
ctrl = 1

;---------------------------------------------------------------------------
; Run forward
[Statedef 100]
type    = S
physics = S
anim = 100
sprpriority = 1

[State 100, 1]
type = VelSet
trigger1 = 1
x = const(velocity.run.fwd.x)

[State 100, 2] ;Prevent run from canceling into walk
type = AssertSpecial
trigger1 = 1
flag = NoWalk

[State 100, 3] ;Prevent from turning
type = AssertSpecial
trigger1 = 1
flag = NoAutoTurn

[State 100, 4]
type = ChangeState
trigger1 = command != "holdfwd"
value = 0

;---------------------------------------------------------------------------
; Hop backwards
[Statedef 105]
type    = A
physics = A
ctrl = 0
anim = 105
sprpriority = 1

[State 105, 1]
type = VelSet
trigger1 = Time = 0
x = const(velocity.run.back.x)
y = const(velocity.run.back.y)

[State 105, 2]
type = CtrlSet
trigger1 = Time = 2
value = 1

[State 105, 3]
type = ChangeState
trigger1 = Vel Y > 0
trigger1 = Pos Y >= 0
value = 106

;---------------------------------------------------------------------------
; Hop backwards (land)
[Statedef 106]
type    = S
physics = S
ctrl = 0
anim = 47

[State 106, 1]
type = VelSet
trigger1 = Time = 0
y = 0

[State 106, 2]
type = PosSet
trigger1 = Time = 0
y = 0

[State 106, 3]
type = MakeDust
trigger1 = Time = 2
pos = 0, 0
spacing = 1

[State 106, 4]
type = VelSet
trigger1 = abs(vel x) < Const(movement.stand.friction.threshold)
x = 0

[State 106, 5]
type = ChangeState
trigger1 = Time = 7
value = 0
ctrl = 1

;---------------------------------------------------------------------------
; Lose (time over)
[Statedef 170]
type = S
ctrl = 0
anim = 170
velset = 0,0

[State 170, 1]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1

;---------------------------------------------------------------------------
; Draw game (time over)
[Statedef 175]
type = S
ctrl = 0
velset = 0,0

[State 175, 1] ; If no anim, use go to lose state.
type = ChangeState
trigger1 = Time = 0
trigger1 = !SelfAnimExist(175)
value = 170

[State 175, 2]
type = ChangeAnim
trigger1 = Time = 0
value = 175

[State 175, 3]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1

;---------------------------------------------------------------------------
; Pre-intro
[Statedef 190]
type = S
ctrl = 0
velset = 0,0

[State 190, 1]
type = ChangeAnim
trigger1 = SelfAnimExist(190)
value = 190

[State 190, 2] ;Go straight to intro.
type = ChangeState
trigger1 = Time = 0
value = 191

;---------------------------------------------------------------------------
; Intro (override this state to give character an intro)
[Statedef 191]
type = S
ctrl = 0

[State 191, 1]
type = ChangeState
trigger1 = Time = 0
value = 0

;---------------------------------------------------------------------------
; Stand get-hit (shaking)
[Statedef 5000]
type    = S
movetype= H
physics = N
velset = 0,0

[State 5000, 1] ;Anim for HIT_LIGHT to HIT_HARD
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) != [3,5]
value = ifelse((GetHitVar(groundtype) = 1),5000,5010) + GetHitVar(animtype)

[State 5000, 2] ;Anim for HIT_BACK
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) = [3,5]
value = 5030

[State 5000, 3] ;Anim for HIT_UP/HIT_DIAGUP (only if it exists)
type = ChangeAnim
trigger1 = Time = 0
trigger1 = (GetHitVar(animtype) = [4,5]) && (SelfAnimExist(5047 + GetHitVar(animtype)))
value = 5047 + GetHitVar(animtype) ;5051 - 4 + type

[State 5000, 4] ;Freeze anim
type = ChangeAnim
trigger1 = Time > 0
value = anim

[State 5000, 5] ;State type gets set to aerial if getting hit up
type = StateTypeSet
trigger1 = Time = 0
trigger1 = GetHitVar(yvel) != 0 || GetHitVar(fall)
trigger2 = Pos Y != 0
statetype = a

[State 5000, FFB Light]
type = ForceFeedback
trigger1 = anim = 5000
trigger2 = anim = 5010
persistent = 0
time = 6
waveform = square

[State 5000, FFB Medium]
type = ForceFeedback
trigger1 = anim = 5001
trigger2 = anim = 5011
persistent = 0
time = 8
waveform = sinesquare
ampl = 110,-1,-.3

[State 5000, FFB Hard]
type = ForceFeedback
trigger1 = anim = 5012
trigger2 = anim = 5002
trigger3 = anim = 5030
persistent = 0
time = 15
waveform = sinesquare
ampl = 140

[State 5000, 6]
type = ChangeState
trigger1 = HitShakeOver
trigger1 = GetHitVar(yvel) = 0 && !GetHitVar(fall)
value = 5001 ;Stand get-hit (knocked back)

[State 5000, 7]
type = ChangeState
trigger1 = HitShakeOver
value = 5030

;---------------------------------------------------------------------------
; Stand get-hit (knocked back)
[Statedef 5001]
type    = S
movetype= H
physics = S

[State 5001, 1]
type = HitVelSet
trigger1 = Time = 0
x = 1

[State 5001, 2]
type = ChangeAnim
trigger1 = AnimTime = 0
value = 5005 + GetHitVar(animtype) + (GetHitVar(groundtype)=2)*10

[State 5001, 3] ;Stop sliding back
type = VelMul
trigger1 = Time >= GetHitVar(slidetime)
x = .6

[State 5001, 4]
type = VelSet
trigger1 = HitOver
x = 0

[State 5001, 5]
type = DefenceMulSet
trigger1 = HitOver
value = 1

[State 5001, 6]
type = ChangeState
trigger1 = HitOver
value = 0
ctrl = 1

;---------------------------------------------------------------------------
; Crouch get-hit (shaking)
[Statedef 5010]
type    = C
movetype= H
physics = N
velset = 0,0

[State 5010, 1] ;Anim for HIT_LIGHT to HIT_HARD
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) != [3,5]
value = 5020 + GetHitVar(animtype)

[State 5010, 2] ;Anim for HIT_BACK
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) = [3,5]
value = 5030

[State 5010, 3] ;Anim for HIT_UP/HIT_DIAGUP (only if it exists)
type = ChangeAnim
trigger1 = Time = 0
trigger1 = (GetHitVar(animtype) = [4,5]) && (SelfAnimExist(5047 + GetHitVar(animtype)))
value = 5047 + GetHitVar(animtype) ;5051 - 4 + type

[State 5010, 4] ;Freeze anim
type = ChangeAnim
trigger1 = Time > 0
value = anim

[State 5010, 5] ;State type gets set to aerial if getting hit up
type = StateTypeSet
triggerall = Time = 0
trigger1 = GetHitVar(yvel) != 0 || GetHitVar(fall)
trigger2 = Pos Y != 0
statetype = a

[State 5010, 6]
type = ChangeState
trigger1 = HitShakeOver
trigger1 = GetHitVar(yvel) = 0 && !GetHitVar(fall)
value = 5011 ;Crouch get-hit (knocked back)

[State 5010, 7]
type = ChangeState
trigger1 = HitShakeOver
value = 5030

[State 5010, FFB Light]
type = ForceFeedback
trigger1 = anim = 5020
persistent = 0
time = 6
waveform = square

[State 5010, FFB Medium]
type = ForceFeedback
trigger1 = anim = 5021
persistent = 0
time = 8
waveform = sinesquare
ampl = 110,-1,-.3

[State 5010, FFB Hard]
type = ForceFeedback
trigger1 = anim = 5022
persistent = 0
time = 15
waveform = sinesquare
ampl = 140

;---------------------------------------------------------------------------
; Crouch get-hit (knocked back)
[Statedef 5011]
type    = C
movetype= H
physics = C

[State 5011, 1]
type = HitVelSet
trigger1 = Time = 0
x = 1

[State 5011, 2]
type = ChangeAnim
trigger1 = AnimTime = 0
value = 5025 + GetHitVar(animtype)

[State 5011, 3] ;Stop sliding back
type = VelMul
trigger1 = Time >= GetHitVar(slidetime)
x = .6

[State 5011, 4]
type = VelSet
trigger1 = HitOver
x = 0

[State 5011, 5]
type = DefenceMulSet
trigger1 = HitOver
value = 1

[State 5011, 6]
type = ChangeState
trigger1 = HitOver
value = 11
ctrl = 1

;---------------------------------------------------------------------------
; Air get-hit (shaking)
[Statedef 5020]
type    = A
movetype= H
physics = N
velset = 0,0

[State 5020, 1] ;Anim for HIT_LIGHT to HIT_HARD
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) != [3,5]
value = ifelse((GetHitVar(airtype) = 1),5000,5010) + GetHitVar(animtype)

[State 5020, 2] ;Anim for HIT_BACK
type = ChangeAnim
trigger1 = Time = 0
trigger1 = GetHitVar(animtype) = [3,5]
value = 5030

[State 5020, 3] ;Anim for HIT_UP/HIT_DIAGUP (only if it exists)
type = ChangeAnim
trigger1 = Time = 0
trigger1 = (GetHitVar(animtype) = [4,5]) && (SelfAnimExist(5047 + GetHitVar(animtype)))
value = 5047 + GetHitVar(animtype) ;5051 - 4 + type

[State 5020, 4] ;Freeze anim
type = ChangeAnim
trigger1 = Time > 0
value = anim

[State 5020, 5]
type = ChangeState
trigger1 = HitShakeOver
value = 5030

[State 5020, FFB Light]
type = ForceFeedback
trigger1 = anim = 5000
trigger2 = anim = 5010
persistent = 0
time = 6
waveform = square

[State 5020, FFB Medium]
type = ForceFeedback
trigger1 = anim = 5001
trigger2 = anim = 5011
persistent = 0
time = 8
waveform = sinesquare
ampl = 110,-1,-.3

[State 5020, FFB Hard]
type = ForceFeedback
trigger1 = anim = 5012
trigger2 = anim = 5002
trigger3 = anim = 5030
trigger4 = anim = [5051,5059]
persistent = 0
time = 15
waveform = sinesquare
ampl = 140

;---------------------------------------------------------------------------
; Air get-hit (knocked away)
[Statedef 5030]
type    = A
movetype= H
physics = N
ctrl = 0

[State 5030, 1]
type = ChangeAnim
trigger1 = Anim != [5000, 5199]
trigger1 = SelfAnimExist(5030)
value = 5030

[State 5030, 2]
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5030, 3]
type = HitVelSet
trigger1 = Time = 0
x = 1
y = 1

[State 5030, 4]
type = ChangeState
triggerall = !HitFall
trigger1 = HitOver
trigger2 = Vel Y > 0    ;Hit ground
trigger2 = Pos Y >= Const(movement.air.gethit.groundlevel)
value = 5040 ;HITA_RECOV

[State 5030, 5]
type = ChangeState
triggerall = HitFall
trigger1 = HitOver
trigger2 = Vel Y > 0    ;Hit ground
trigger2 = Pos Y >= Const(movement.air.gethit.groundlevel)
value = 5050 ;HITA_FALL

[State 5030, 6]
type = ChangeState
trigger1 = AnimTime = 0
value = 5035 ;Air get-hit (transition)

;---------------------------------------------------------------------------
; Air get-hit (transition)
[Statedef 5035]
type    = A
movetype= H
physics = N

[State 5035, 1]
type = ChangeAnim
trigger1 = Time = 0
trigger1 = SelfAnimExist(5035)
trigger1 = Anim != [5051,5059] ;Not if in hit up anim
trigger1 = Anim != 5090 ;Not if hit off ground anim
value = 5035

[State 5035, 2]
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5035, 3]
type = ChangeState
triggerall = !HitFall
trigger1 = HitOver  ;Hit is over
trigger2 = AnimTime = 0 ;Animation over
trigger3 = Vel Y > 0    ;Hit ground
trigger3 = Pos Y >= Const(movement.air.gethit.groundlevel)
trigger4 = Time = 0     ;No transition anim
trigger4 = Anim != 5035 ;.
value = 5040 ;Air get-hit (recovering in air, not falling)

[State 5035, 4]
type = ChangeState
triggerall = HitFall
trigger1 = HitOver  ;Hit is over
trigger2 = AnimTime = 0 ;Anim is over
trigger3 = Vel Y > 0    ;Hit ground
trigger3 = Pos Y >= Const(movement.air.gethit.groundlevel)
trigger4 = Time = 0     ;No transition anim
trigger4 = Anim != 5035 ;.
value = 5050 ;Air get-hit (falling)

;---------------------------------------------------------------------------
; Air get-hit (recovering in air, not falling)
[Statedef 5040]
type    = A
movetype= H
physics = N

[State 5040, 1]
type = ChangeState
trigger1 = !Alive
value = 5050
ctrl = 0

[State 5040, 2]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = Anim != 5040
trigger2 = Time = 0
trigger2 = Anim != 5035
value = 5040

[State 5040, 3]
type = CtrlSet
trigger1 = HitOver
value = 1

[State 5040, 4]
type = StateTypeSet
trigger1 = HitOver
movetype = I

[State 5040, 5]
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5040, 6]
type = ChangeState
trigger1 = Vel Y > 0
trigger1 = Pos Y >= 0
value = 52 ;Jump land

;---------------------------------------------------------------------------
; Air get-hit (falling)
[Statedef 5050]
type    = A
movetype= H
physics = N

[State 5050, 1] ;Change anim when done with transition
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = Anim = 5035
trigger2 = Time = 0     ;If no transition anim
trigger2 = Anim != 5035
trigger2 = (Anim != [5051, 5059]) && (Anim != [5061, 5069])
trigger2 = Anim != 5090 ;Not if hit off ground anim
value = 5050

[State 5050, 2] ;Coming down anim
type = ChangeAnim
trigger1 = anim = [5050,5059]
trigger1 = Vel Y >= ifelse(anim = 5050, Const720p(4), Const720p(-8))
trigger1 = SelfAnimExist(anim+10)
value = anim+10
persistent = 0

[State 5050, 3] ;Gravity
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5050, 4] ;Recover near ground
type = ChangeState
triggerall = Vel Y > 0
triggerall = Pos Y >= Const(movement.air.gethit.groundrecover.ground.threshold)
triggerall = alive
triggerall = CanRecover
trigger1 = Command = "recovery"
value = 5200 ;Air get-hit (fall recovery on ground)

[State 5050, 5]; Recover in mid air
type = ChangeState
triggerall = Vel Y > Const(movement.air.gethit.airrecover.threshold)
triggerall = alive
triggerall = CanRecover
trigger1 = Command = "recovery"
value = 5210 ;Air get-hit (fall recovery in air)

[State 5050, 6]
type = ChangeState
trigger1 = Vel Y > 0
trigger1 = Pos Y >= ifelse((anim = [5051,5059]) || (anim = [5061,5069]), 0, Const(movement.air.gethit.groundlevel))
value = 5100 ;Downed get-hit (hit ground from fall)

;---------------------------------------------------------------------------
; Tripped get-hit (shaking)
[Statedef 5070]
type    = A
movetype= H
physics = N
velset = 0,0

[State 5070, 1]
type = ChangeAnim
trigger1 = 1
value = 5070

[State 5070, 2]
type = ChangeState
trigger1 = HitShakeOver
value = 5071

[State 5070, 3]
type = ForceFeedback
trigger1 = time = 0
time = 12
waveform = sinesquare
ampl = 140

;---------------------------------------------------------------------------
; Tripped get-hit (knocked away)
[Statedef 5071]
type    = A
movetype= H
physics = N

[State 5071, 1]
type = HitVelSet
trigger1 = Time = 0
x = 1
y = 1

[State 5071, 2] ;Acceleration
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5071, 3] ;Hit ground
trigger1 = Vel Y > 0
trigger1 = Pos Y >= Const(movement.air.gethit.trip.groundlevel)
type = ChangeState
value = 5110

;---------------------------------------------------------------------------
; Downed get-hit (shaking)
[Statedef 5080]
type    = L
movetype= H
physics = N
velset = 0,0

[State 5080, 1] ;Set default anim
type = VarSet
trigger1 = time = 0
sysvar(2) = ifelse (GetHitVar(yvel) = 0, 5080, 5090)

[State 5080, 2]
type = VarAdd
trigger1 = time = 0
trigger1 = (anim = [5081,5089]) || (anim = [5111,5119])
trigger1 = SelfAnimExist(sysvar(2) + (anim % 10))
sysvar(2) = anim % 10

[State 5080, 3] ;If 5090 doesnt exist, default to 5030
type = VarSet
trigger1 = time = 0
trigger1 = sysvar(2) = 5090
trigger1 = !SelfAnimExist(5090)
sysvar(2) = 5030

[State 5080, 3] ;Freeze
type = ChangeAnim
trigger1 = 1
value = sysvar(2)

[State 5080, 4]
type = ChangeState
trigger1 = HitShakeOver
trigger1 = GetHitVar(yvel) = 0
value = 5081 ;Downed get-hit (knocked back)

[State 5080, 5]
type = ChangeState
trigger1 = HitShakeOver
trigger1 = GetHitVar(yvel) != 0
value = 5030 ;Air get-hit (knocked away)

;---------------------------------------------------------------------------
; Downed get-hit (knocked back)
[Statedef 5081]
type    = L
movetype= H
physics = C

[State 5081, 1]
type = HitVelSet
trigger1 = Time = 0
x = 1

[State 5081, 2]
type = VelSet
trigger1 = HitOver
x = 0

[State 5081, 3] ;Dont show hit ground frame
type = VarSet
trigger1 = Time = 0
sysvar(0) = 1

[State 5081, 4]
type = ChangeState
trigger1 = HitOver
value = 5110 ;Downed get-hit (lying down)

;---------------------------------------------------------------------------
; Downed get-hit (hit ground from fall)
[Statedef 5100]
type    = L
movetype= H
physics = N

[State 5100, 2004.04.14 behavior]
type = null;VelSet
trigger1 = Time = 0
trigger1 = GetHitVar(fall.yvel) = 0
trigger1 = vel x < -1
x = -1

[State 5100, EnvShake]
type = FallEnvShake
trigger1 = Time = 0

[State 5100, Var] ;Save fall velocity
type = VarSet
trigger1 = Time = 0
sysvar(1) = floor(vel y)

[State 5100, 2] ;Hit ground anim (normal)
type = ChangeAnim
triggerall = time = 0
trigger1 = (anim != [5051,5059]) && (anim != [5061,5069])
trigger2 = !SelfAnimExist(5100 + (anim % 10))
value = 5100

[State 5100, 3] ;Hit ground anim (for hit up)
type = ChangeAnim
trigger1 = time = 0
trigger1 = (anim = [5051,5059]) || (anim = [5061,5069])
trigger1 = SelfAnimExist(5100 + (anim % 10))
value = 5100 + (anim % 10)

[State 5100, 4]
type = PosSet
trigger1 = Time = 0
y = 0

[State 5100, 5]
type = VelSet
trigger1 = Time = 0
y = 0

[State 5100, 6] ;Reduce speed
type = VelMul
trigger1 = Time = 0
x = 0.75

[State 5100, 7]
type = ChangeState
trigger1 = Time = 0
trigger1 = GetHitVar(fall.yvel) = 0
value = 5110 ;Downed get-hit (lying down)

[State 5100, 8]
type = Explod
trigger1 = Time = 1
anim = F(60 + (sysvar(1) > Const720p(20)) + (sysvar(1) > Const720p(56)))
pos = 0, 0
sprpriority = ifelse (sysvar(1) <= Const720p(56), -10, 10)

[State 5100, 9]
type = HitFallDamage
trigger1 = Time = 3

[State 5100, 10]
type = PlaySnd
trigger1 = Time = 1
value = F7, (sysvar(1) > Const720p(20)) + (sysvar(1) > Const720p(56))

[State 5100, 11]
type = PosFreeze
trigger1 = 1

[State 5100, 12]
type = ChangeState
trigger1 = AnimTime = 0
value = 5101 ;Downed get-hit (bounce off ground)

[State 5100, 13]
type = ForceFeedback
trigger1 = Time = 0
waveform = sinesquare
ampl = 128,-3,-.2,.005
time = 20

;---------------------------------------------------------------------------
; Downed get-hit (bounce off ground)
[Statedef 5101]
type    = L
movetype= H
physics = N

[State 5101, 1] ;Coming hit ground anim (normal)
type = ChangeAnim
triggerall = time = 0
trigger1 = anim != [5101,5109]
trigger2 = !SelfAnimExist(5160 + (anim % 10))
value = 5160

[State 5101, 2] ;Coming hit ground anim (for hit up)
type = ChangeAnim
triggerall = time = 0
trigger1 = anim = [5101,5109]
trigger1 = SelfAnimExist(5160 + (anim % 10))
value = 5160 + (anim % 10)

[State 5101, 3]
type = HitFallVel
trigger1 = Time = 0

[State 5101, 4]
type = PosSet
trigger1 = Time = 0
y = Const(movement.down.bounce.offset.y)

[State 5101, 5]
type = PosAdd
trigger1 = Time = 0
x = Const(movement.down.bounce.offset.x)

[State 5101, 6] ;Acceleration
type = VelAdd
trigger1 = 1
y = Const(movement.down.bounce.yaccel)

[State 5101, 7] ;Hit ground
trigger1 = Vel Y > 0
trigger1 = Pos Y >= Const(movement.down.bounce.groundlevel)
type = ChangeState
value = 5110

;---------------------------------------------------------------------------
; Downed get-hit (lying down)
[Statedef 5110]
type    = L
movetype= H
physics = N

[State 5110, EnvShake]
type = FallEnvShake
trigger1 = Time = 0

[State 5110, 1] ;For hit up/up-diag type (from state 5081)
type = ChangeAnim
persistent = 0
trigger1 = SelfAnimExist(5110 + (anim % 10))
trigger1 = anim = [5081,5089]
value = 5110 + (anim % 10)

[State 5110, 2] ;Hit ground anim (normal)
type = ChangeAnim
triggerall = time = 0
triggerall = anim != [5110,5119] ;Not already changed anim
trigger1 = anim != [5161,5169]
trigger2 = !SelfAnimExist(5170 + (anim % 10))
value = 5170

[State 5110, 3] ;Hit ground anim (for hit up)
type = ChangeAnim
triggerall = time = 0
triggerall = anim != [5110,5119] ;Not already changed anim
trigger1 = anim = [5161,5169]
trigger1 = SelfAnimExist(5170 + (anim % 10))
value = 5170 + (anim % 10)

[State 5110, 4]
type = HitFallDamage
trigger1 = Time = 0

[State 5110, 5]
type = PosSet
trigger1 = Time = 0
y = 0

[State 5110, Var] ;Get fall velocity
type = VarSet
trigger1 = Time = 0
trigger1 = GetHitVar(fall.yvel) != 0
sysvar(1) = floor(vel y)

[State 5110, 6]
type = PlaySnd
trigger1 = Time = 0
trigger1 = !SysVar(0)
value = F7, (sysvar(1) > Const720p(20)) + (sysvar(1) > Const720p(56))

[State 5110, 7]
type = Explod
trigger1 = Time = 0
trigger1 = !SysVar(0)
anim = F(60 + (sysvar(1) > Const720p(20)) + (sysvar(1) > Const720p(56)))
pos = 0, 0
sprpriority = ifelse (sysvar(1) <= Const720p(56), -10, 10)

[State 5110, 8]
type = VelSet
trigger1 = Time = 0
y = 0

[State 5110, 9] ;For hit up type
type = ChangeAnim
persistent = 0
triggerall = anim = [5171,5179]
triggerall = SelfAnimExist(5110 + (anim % 10))
trigger1 = AnimTime = 0
trigger2 = SysVar(0) ;SysVar(0) = 1 avoids hit ground anim
value = 5110 + (anim % 10)

[State 5110, 10] ;For normal
type = ChangeAnim
persistent = 0
triggerall = Anim != [5111,5119]
trigger1 = AnimTime = 0
trigger2 = SysVar(0) ;SysVar(0) = 1 avoids hit ground frame
value = 5110

[State 5110, 11] ;If just died
type = ChangeState
triggerall = !alive
trigger1 = AnimTime = 0
trigger2 = SysVar(0) ;SysVar(0) = 1 avoids hit ground frame
trigger3 = Anim = [5110,5119]
value = 5150

[State 5110, 12]
type = VarSet
trigger1 = SysVar(0)
trigger1 = Time = 0
sysvar(0) = 0

[State 5110, 13] ;Friction
type = VelMul
trigger1 = 1
x = 0.85

[State 5110, 14] ;Friction
type = VelSet
trigger1 = abs(Vel x) < Const(movement.down.friction.threshold)
persistent = 0
x = 0

[State 5110, 15]
type = ForceFeedback
trigger1 = alive
trigger1 = Time = 0
time = 8
ampl = 240
waveform = sine

[State 5110, 16]
type = ForceFeedback
trigger1 = !alive
trigger1 = Time = 0
ampl = 200, 7, -.467
time = 30
waveform = sine

;---------------------------------------------------------------------------
; Downed get-hit (getting up)
[Statedef 5120]
type    = L
movetype= I
physics = N

[State 5120, 1a] ;Get up anim (normal)
type = ChangeAnim
triggerall = time = 0
trigger1 = anim != [5111,5119]
trigger2 = !SelfAnimExist(5120 + (anim % 10))
value = 5120

[State 5120, 1b] ;Get up anim (for hit up/diag-up)
type = ChangeAnim
triggerall = time = 0
trigger1 = anim = [5111,5119]
trigger1 = SelfAnimExist(5120 + (anim % 10))
value = 5120 + (anim % 10)

[State 5120, 2]
type = VelSet
trigger1 = Time = 0
x = 0

[State 5120, 3]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1

[State 5120, 4]
type = HitFallSet
trigger1 = AnimTime = 0
value = 1

[State 5120, 5] ;Cant be thrown right after getting up
type = NotHitBy
trigger1 = AnimTime = 0
value = , NT,ST,HT
time = 12

[State 5120, 6] ;Cant be hit right after getting up (short time)
type = NotHitBy
trigger1 = AnimTime = 0
value2 = SCA
time = 1

[State 5120, 7]
type = SelfState
trigger1 = AnimTime = 0
value = 0
ctrl = 1

;---------------------------------------------------------------------------
; Downed get-hit (lying defeated)
[Statedef 5150]
type    = L
movetype= H
physics = N
sprpriority = -3
ctrl = 0

[State 5150, 1] ;Normal anim
type = ChangeAnim
triggerall = Time = 0
triggerall = SelfAnimExist(5140)
trigger1 = (anim != [5111,5119]) && (anim != [5171,5179])
trigger2 = !SelfAnimExist(5140 + (anim % 10))
value = 5140

[State 5150, 3] ;Hit up type anim
type = ChangeAnim
trigger1 = Time = 0
trigger1 = (anim = [5111,5119]) || (anim = [5171,5179])
trigger1 = SelfAnimExist(5140 + (anim % 10))
value = 5140 + (anim % 10)

[State 5150, 4] ;Match over anim
type = ChangeAnim
persistent = 0
;trigger1 = Time = 0
trigger1 = MatchOver = 1
trigger1 = Anim = [5140,5149]
trigger1 = SelfAnimExist(anim+10)
value = anim+10

[State 5150, 5] ;Switch to 5110 if liedead anim does not exist
type = ChangeAnim
trigger1 = Time = 0
trigger1 = Anim != [5140,5159]
trigger1 = Anim != [5110,5119]
value = 5110

[State 5150, 6] ;Friction
type = VelMul
trigger1 = 1
x = 0.85

[State 5150, 7] ;Friction
type = VelSet
trigger1 = abs(Vel x) < Const(movement.down.friction.threshold)
persistent = 0
x = 0

[State 5150, 8]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1

;---------------------------------------------------------------------------
; Air get-hit (fall recovery on ground; still falling)
[Statedef 5200]
type    = A
movetype= H
physics = N

[State 5200, 1] ;Change anim if done with transition
type = ChangeAnim
trigger1 = Anim = 5035
trigger1 = AnimTime = 0
value = 5050

[State 5200, 2]
type = VelAdd
trigger1 = 1
y = GetHitVar(yaccel)

[State 5200, 3]
type = SelfState
trigger1 = Vel Y > 0
trigger1 = Pos Y >= Const(movement.air.gethit.groundrecover.groundlevel)
value = 5201

;---------------------------------------------------------------------------
; Air get-hit (fall recovery on ground)
[Statedef 5201]
type    = A
movetype= H
physics = A
anim = 5200

[State 5201, 1] ;Turn if not facing opponent
type = Turn
trigger1 = Time = 0
trigger1 = p2dist X < Const720p(-20)

[State 5201, 2]
type = VelSet
trigger1 = Time = 0
x = Const(velocity.air.gethit.groundrecover.x)
y = Const(velocity.air.gethit.groundrecover.y)

[State 5201, 3]
type = PosSet
trigger1 = Time = 0
y = 0

[State 5201, 4]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1

[State 5201, 5] ;Blink white
type = PalFX
trigger1 = Time = 0
time = 3
add = 128,128,128 ;256,256,256

[State 5201, 4]
type = NotHitBy
trigger1 = AnimTime = 0
value = SCA
time = 1


[State 5201, 6]
type = Explod
trigger1 = Time = 0
anim = F60
pos = 0, -floor(vel y)
sprpriority = -10

;---------------------------------------------------------------------------
; Air get-hit (fall recovery in air)
[Statedef 5210]
type    = A
movetype= I
physics = N
anim = 5210
ctrl = 0

[State 5210, 1] ;Blink white
type = PalFX
trigger1 = Time = 0
time = 3
add = 128,128,128

[State 5210, 1]
type = PosFreeze
trigger1 = Time < 4

[State 5210, 2] ;Turn if not facing opponent
type = Turn
trigger1 = Time = 0
trigger1 = p2dist X < Const720p(-80)

[State 5210, 1.0 behavior 1]
type = VelMul
trigger1 = Time = 4
x = Const(velocity.air.gethit.airrecover.mul.x)
y = Const(velocity.air.gethit.airrecover.mul.y)

[State 5210, 1.0 behavior 2]
type = VelAdd
trigger1 = Time = 4
x = Const(velocity.air.gethit.airrecover.add.x)
y = Const(velocity.air.gethit.airrecover.add.y)

[State 5210, 2002.04.14 behavior 1]
type = null;VelMul
trigger1 = Time = 4
x = .8
y = .8

[State 5210, 2002.04.14 behavior 2]
type = null;VelAdd
trigger1 = Time = 4
x = 0 
y = -4.5

[State 5210, 2002.04.14 behavior 3]
type = null;VelMul
trigger1 = Time = 4
trigger1 = Vel Y > 0
y = .5

[State 5210, 2002.04.14 behavior 4]
type = null;VelAdd
trigger1 = Time = 4
trigger1 = Vel Y > -3
y = -2

[State 5210, 2002.04.14 behavior 5]
type = null;VelAdd
trigger1 = Time = 4
trigger1 = Vel Y > -2
y = -1

[State 5210, 2] ;Go up
type = VelAdd
trigger1 = Time = 4
trigger1 = Command = "holdup"
y = Const(velocity.air.gethit.airrecover.up)

[State 5210, 2] ;Go down
type = VelAdd
trigger1 = Time = 4
trigger1 = Command = "holddown"
y = Const(velocity.air.gethit.airrecover.down)

[State 5210, 2] ;Go fwd
type = VelAdd
trigger1 = Time = 4
trigger1 = Command = "holdfwd"
x = Const(velocity.air.gethit.airrecover.fwd)

[State 5210, 2] ;Go back
type = VelAdd
trigger1 = Time = 4
trigger1 = Command = "holdback"
x = Const(velocity.air.gethit.airrecover.back)

[State 5210, 3]
type = NotHitBy
trigger1 = Time = 0
value = SCA
time = 15

[State 5210, 4]
type = CtrlSet
trigger1 = Time = 20
value = 1

[State 5210, 5]
type = VelAdd
trigger1 = Time >= 4
y = Const(movement.air.gethit.airrecover.yaccel)

[State 5210, 5] ;Land on ground
type = ChangeState
trigger1 = Vel Y > 0
trigger1 = Pos Y >= 0
value = 52 ;Jump land
ctrl = 1

;---------------------------------------------------------------------------
; Continue screen animation
[Statedef 5500]
type = S
ctrl = 0
anim = 5300
velset = 0,0

[State 5500, 1] ;Use continue animation if available
type = ChangeAnim
trigger1 = time = 0
trigger1 = SelfAnimExist(5500)
value = 5500

;---------------------------------------------------------------------------
; Initialize (at the start of the round)
[Statedef 5900]
type = S

[State 5900, 1] ;Clear all int variables
type = VarRangeSet
trigger1 = roundsexisted = 0
value = 0

[State 5900, 2] ;Clear all float variables
type = VarRangeSet
trigger1 = roundsexisted = 0
fvalue = 0

[State 5900, 3] ;Change palette
type = RemapPal
trigger1 = 1
source = 1,1
dest = 1,palno

[State 5900, 4] ;Intro for round 1
type = ChangeState
trigger1 = roundno = 1
value = 190

[State 5900, 5] ;All other rounds
type = ChangeState
trigger1 = 1
value = 0