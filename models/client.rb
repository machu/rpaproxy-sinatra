# -*- coding: utf-8 -*-
#
require 'mongoid'
require './models/log'

class Client
	module Status
		ACTIVE = "active"
		SUSPENDED = "suspended"
		BANNED = "banned"
	end

	include Mongoid::Document
	include Mongoid::Timestamps

	field :atag,            type: String
	field :status,          type: String,  default: Status::ACTIVE
	field :suspended_times, type: Integer, default: 0
	field :suspended_at,    type: DateTime

	index({ atag: 1 }, { unique: true} )
	validates_uniqueness_of :atag

	RATE_LIMIT = 30           # request per minutes
	SUSPENDED_LIMIT = 5       # suspended times to banned
	SUSPENDED_DURATION = 3600 # 1hour

	# after_initialize :update_status

	def update_status
		case status
		when Status::ACTIVE
			if rate_limit_exceed?
				self.suspended_times += 1
				if suspended_times < SUSPENDED_LIMIT
					self.status = Status::SUSPENDED
					self.suspended_at = Time.now
				else
					self.status = Status::BANNED
				end
			end
		when Status::SUSPENDED
			unless in_suspend_duration?
				self.status = Status::ACTIVE
				self.suspended_at = nil
				self.suspended_times = 0
			end
		end
	end

	def rate_limit_exceed?
		one_minute_ago = Time.now - 60
		Log.where(:created_at.gte => one_minute_ago).in(atag: atag).count > RATE_LIMIT
	end

	def in_suspend_duration?
		return false if status != Status::SUSPENDED
		return true unless suspended_at

		one_hour_ago = Time.now - 3600
		suspended_at > one_hour_ago
	end
end