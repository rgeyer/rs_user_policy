# Copyright (c) 2012 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module UserAssignments
  # @return [Int] The number of users in the user assignments object
  def length
    raise NotImplementedError, "Please implement this in your concrete class"
  end

  # @return [Int] The number of users in the user assignments object
  def size
    raise NotImplementedError, "Please implement this in your concrete class"
  end

  # Returns the role assigned to the user.  If the user does not exist
  # they should be automatically created with the role "immutable"
  #
  # @param [String] email The email address for the user
  #
  # @return [String] The role assigned to the user
  def get_role(email)
    raise NotImplementedError, "Please implement this in your concrete class"
  end

  # Deletes a user from the user assignments
  #
  # @param [String] email The email address for the user
  def delete(email)
    raise NotImplementedError, "Please implement this in your concrete class"
  end

  # Commits any changes made to the UserAssignments object back to
  # it's original data store.  This is an opportunity to perform
  # DB flushes or write back to a source file.
  #
  # @param [Hash] options A hash of values which may be required to serialize
  def serialize(options={})
    raise NotImplementedError, "Please implement this in your concrete class"
  end
end