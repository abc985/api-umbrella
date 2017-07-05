local Model = require("lapis.db.model").Model
local validation = require "resty.validation"
local iso8601 = require "api-umbrella.utils.iso8601"
local model_ext = require "api-umbrella.utils.model_ext"
local cjson = require "cjson"

local json_null = cjson.null
local validate_field = model_ext.validate_field

local function validate(values)
  local errors = {}
  validate_field(errors, values, "name", validation.string:minlen(1), "can't be blank")
  validate_field(errors, values, "host", validation.string:minlen(1), "can't be blank")
  validate_field(errors, values, "host", validation:regex([[^(\*|(\*\.|\.)[a-zA-Z0-9:][a-zA-Z0-9\-\.:]*|[a-zA-Z0-9:][a-zA-Z0-9\-\.:]*)$]], "jo"), 'must be in the format of "example.com"')
  validate_field(errors, values, "path_prefix", validation.string:minlen(1), "can't be blank")
  validate_field(errors, values, "path_prefix", validation:regex("^/", "jo"), 'must start with "/"')
  return errors
end

local ApiScope = Model:extend("api_scopes", {
  update = model_ext.update({ validate = validate }),

  as_json = function(self)
    return {
      id = self.id or json_null,
      name = self.name or json_null,
      host = self.host or json_null,
      path_prefix = self.path_prefix or json_null,
      created_at = iso8601.format_postgres(self.created_at) or json_null,
      created_by = self.created_by or json_null,
      updated_at = iso8601.format_postgres(self.updated_at) or json_null,
      updated_by = self.updated_by or json_null,
      deleted_at = json_null,
      version = 1,
    }
  end,
})

ApiScope.create = model_ext.create({ validate = validate })

return ApiScope