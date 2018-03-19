# TWCManager

Currently this is a direct fork of cdragon's project that uses RS-485 to throttle down the charge rate of the Tesla Wall Connector(TWC) (Level 2 EV Charger) using the TWC's own Master-Slave functionality to share one electrical circuit for two to four wall chargers.

THANK YOU cdragon for reverse engineering Tesla's Master-Slave protocol!

I have a Tesla Model 3, two Powerwall 2s, and 6.5 kW of Solar panels.
The idea is to be able to use my excess solar power, that would normally go to the grid, to charge my vehicle.

Current status:  
-I've changed the curl to pull stats from the Tesla Powerwall gateway on the local lan for grid power production/usage.

Future plans:

My plans for this project is to integrate the Tesla Vehicle API, the JSON feed from the Tesla Powerwall 2s for instantaneous power flow data, and RS-485 to accomplish the same goal with some added controls.

-Utilize a raspberry pi inside my house and one pair of CAT5e already in my walls for the RS-485. I'm hoping the CAT5e wires are large enough for the screw terminals in the TWC - if not, then I'll spin up another Raspberry Pi in the garage next to the TWC and use the recommended 18 guage wire that the TWC manual suggests.
-Use this USB to RS-485 adapter: https://www.amazon.com/gp/product/B00NKAJGZM
-The forums suggest that the latest TWCs being manufactured have been changed in some way which prevents cdragon's original implementation from terminating car charging: https://teslamotorsclub.com/tmc/threads/new-wall-connector-load-sharing-protocol.72830/  - Therefore I'll be implementing Tesla Vehicle API calls

Tesla Vehicle API calls:
1) Monitor the Vehicle's battery SOC 
2) Control charging (start & stop)
3) Verify vehicle position 

Poll Powerwall 2 JSON output:
-SOC - Powerwall state of charge
-instant_power of site(aka grid) / battery / load (aka my House) / solar


Script logic outline:

-If not During daylight hours (6am-9pm)
	if we started charging with this script
		stop charging
		save state - stopped charging
	exit 0

-If not "enable charging with excess solar" via toggle switch in webUI
	If we started charging with this script
	then 
		stop charging
		save state - stopped charging
		exit 0
	else 
		exit 0 

-Pull powerwall stats
	http://<local-ip-of-powerwall-gateway>/api/meters/aggregates  (ie "site":"instant_power" > -1500 watts ) - The minimum charge rate that the car will accept from the TWC is 6 amps.  ( 6 amps x 240 Volts = 1440Watts )  
	if instant_power > -1500 watts then
		exit 0 - not enough solar to charge car

-Pull vehicle status from Tesla API 
	-login/use existing token
	-if car isn't currently charging - save state - not charging

-If not (in my garage && plugged in)
	exit 0

(Optional) {
-Powerwall Battery SOC? (Should be 100% (+/- 1%))  http://<local-ip-of-powerwall-gateway>/api/system_status/soe
	if SOC > 99% then continue
	else if soc < 99% then check other conditions for Powerwall vs Car priority settings
		do stuff (TBD)
}

{not necessary?}
-if ( Vehicle SOC => set point && we're currently charging )
	stop charging via tesla car api (is this necessary? wouldn't the car stop on its own?)
	save state - stopped charging
	(email/txt/google hangout notify - charging complete) 
	exit 0


-if ( Vehicle SOC below set point && currently charging )
	then
		print debug
		exit 0


-If ( Vehicle SOC below set point &&  not currently charging )
	-If not sending enough power to the grid
	then 
		exit 0 - not enough power to solar charge the car 
	else
		-limit charge current to TWC: ( site:instant_power / 240 ) = amps (set via RS-485 commands)
		-start charging car via tesla car api.
		-confirm charging started else throw error
		-save state - started charging 


-loop every x minutes.




Powerwall optional settings modifications:  
(Other possible features:
-Prioritize Powerwall over Car charging 
-Prioritize Car charging over powerwall) (or Load share) - 6 Amp minimum to car and the remainder to powerwall.
-Option to change the Powerwall Battery "Reserve for Power Outages"?
-Option to change the Powerwall mode from "Self-Powered" to "Backup-only" for night time charges so we aren't using a battery to charge a battery?







Here is the remainder of cdragon's README.md:
TWCManager lets you control the amount of power delivered by a Tesla Wall Connector (TWC) to the car it's charging.

Due to hardware limitations, TWCManager will not work with Tesla's older High Power Wall Connector (HPWC) EVSEs that were discontinued around April 2016.

See **TWCManager Installation.pdf** for how to install and use.
