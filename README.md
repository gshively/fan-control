When Dell T320 iDrac no longer is monitoring temp of drives and
dynamically controlling the speed of the fan, it instead sets it
to a large value.

Using IPMI, gathering CPU temps and dynamically set power provided
to the FAN, thereby controlling fan speed based on CPU temp. Keeps
the fan quiet, but spins up when CPU temps increase.

