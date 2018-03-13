# ntp servers can be an array of servers
#   or
# a hash where the keys are servers and the values are an array of options
type Ntpd::Servers = Variant[
  Array[String],
  Hash[String, Array[String]]
]
