<?php declare(strict_types=1);
/*
    part-db version 0.1
    Copyright (C) 2005 Christoph Lechner
    http://www.cl-projects.de/

    part-db version 0.2+
    Copyright (C) 2009 K. Jacobs and others (see authors.php)
    http://code.google.com/p/part-db/

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
*/

namespace PartDB;

use Exception;
use PartDB\Permissions\PartContainingPermission;
use PartDB\Permissions\PermissionManager;

/**
 * @file Device.php
 * @brief class Device
 *
 * @class Device
 * All elements of this class are stored in the database table "devices".
 *
 *    There cannot be more than one DeviceParts with the same Part in a Device!
 *          The Reason is, that it would be quite complicated to "calculate" if there are enough parts in stock.
 *          Example: If there is the same Part in a Device two times and only one Part in stock.
 *          Which one should be marked as "enought in stock", which one as "not enought in stock"?
 *          So it's better if every Part can only be one time in a Device...
 *
 */
class Device extends Base\PartsContainingDBElement
{
    const TABLE_NAME = 'devices';

    /********************************************************************************
     *
     *   Constructor / Destructor / reset_attributes()
     *
     *********************************************************************************/

    /** This creates a new Element object, representing an entry from the Database.
     *
     * @param Database $database reference to the Database-object
     * @param User $current_user reference to the current user which is logged in
     * @param Log $log reference to the Log-object
     * @param integer $id ID of the element we want to get
     * @param array $db_data If you have already data from the database,
     * then use give it with this param, the part, wont make a database request.
     *
     * @throws \PartDB\Exceptions\TableNotExistingException If the table is not existing in the DataBase
     * @throws \PartDB\Exceptions\DatabaseException If an error happening during Database AccessDeniedException
     * @throws \PartDB\Exceptions\ElementNotExistingException If no such element exists in DB.
     */
    protected function __construct(Database &$database, User &$current_user, Log &$log, int $id, $data = null)
    {
        parent::__construct($database, $current_user, $log, $id, $data);
    }

    protected function getVirtualData(int $virtual_id): array
    {
        $tmp = parent::getVirtualData($virtual_id); // TODO: Change the autogenerated stub

        if ($virtual_id == 0) {
            // this is the root node
            $tmp['order_quantity'] = 0;
            $tmp['order_only_missing_parts'] = false;
        }

        return $tmp;
    }

    /********************************************************************************
     *
     *   Basic Methods
     *
     *********************************************************************************/

    /**
     *  Delete this device (with all DeviceParts in it)
     *
     * @note    This function overrides the same-named function from the parent class.
     * @note    The DeviceParts in this device will be deleted too (not the parts itself,
     *          but the entries in the table "device_parts").
     *
     * @param boolean $delete_recursive         If true, all subdevices will be deleted too (!!)
     * @param boolean $delete_files_from_hdd    @li if true, the attached files of this device will be deleted from
     *                                              harddisc drive (!) See AttachementContainingDBElement::delete()
     *                                          @li if false, only the attachement records in the database will be
     *                                              deleted, but not the files on the harddisc
     *
     * @throws Exception if there was an error
     *
     * @see FilesContainingDBElement::delete()
     * @see DevicePart::delete()
     */
    public function delete(bool $delete_recursive = false, bool $delete_files_from_hdd = false)
    {
        try {
            $transaction_id = $this->database->beginTransaction(); // start transaction

            // work on subdevices (delete or move up)
            $subdevices = $this->getSubelements(false);
            foreach ($subdevices as $device) {
                if ($delete_recursive) {
                    $device->delete($delete_recursive, $delete_files_from_hdd);
                } // delete all subdevices
                else {
                    $device->setParentID($this->getParentID());
                } // set new parent ID
            }

            // delete all device-parts in this device
            $device_parts = $this->getParts(false); // DevicePart object, not Part objects!
            $this->resetAttributes(); // to set $this->parts to NULL
            foreach ($device_parts as $device_part) {
                $device_part->delete();
            }

            // now we can delete this element + all attachements of it
            parent::delete($delete_files_from_hdd);

            $this->database->commit($transaction_id); // commit transaction
        } catch (Exception $e) {
            $this->database->rollback(); // rollback transaction

            // restore the settings from BEFORE the transaction
            $this->resetAttributes();

            throw new Exception(sprintf(_('Die Baugruppe "%s" konnte nicht gelöscht werden!\n'), $this->getName()) . _('Grund: ').$e->getMessage());
        }
    }

    /**
     *  Create a new Device as a copy from this one. All DeviceParts will be copied too.
     *
     * @param string $name                  The name of the new device
     * @param integer $parent_id            The ID of the new device's parent device
     * @param boolean   $with_subdevices    If true, all subdevices will be copied too
     *
     * @throws Exception if there was an error
     */
    public function copy(string $name, int $parent_id, bool $with_subdevices = false)
    {
        try {
            if ($with_subdevices && ($parent_id > 0)) { // the root node (ID 0 or -1) is always allowed as the parent object
                // check if $parent_id is NOT a child of this device
                $parent_device = Device::getInstance($this->database, $this->current_user, $this->log, $parent_id);

                if (($parent_device->getID() == $this->getID()) || $parent_device->isChildOf($this)) {
                    throw new Exception(_('Eine Baugruppe kann nicht in sich selber kopiert werden!'));
                }
            }

            $transaction_id = $this->database->beginTransaction(); // start transaction

            $new_device = Device::add($this->database, $this->current_user, $this->log, $name, $parent_id);

            $device_parts = $this->getParts();
            foreach ($device_parts as $part) {
                /** @var DevicePart $part */
                $new_part = DevicePart::add(
                    $this->database,
                    $this->current_user,
                    $this->log,
                    $new_device->getID(),
                    $part->getPart()->getID(),
                    $part->getMountQuantity(),
                    $part->getMountNames()
                );
            }

            if ($with_subdevices) {
                $subdevices = $this->getSubelements(false);
                foreach ($subdevices as $device) {
                    $device->copy($device->getName(), $new_device->getID(), true);
                }
            }

            $this->database->commit($transaction_id); // commit transaction
        } catch (Exception $e) {
            $this->database->rollback(); // rollback transaction

            throw new Exception(sprintf(_("Die Baugruppe \"%s\"konnte nicht kopiert werden!\n"), $this->getName()) . _('Grund: ').$e->getMessage());
        }
    }

    /**
     *  Book all parts (decrease or increase instock)
     *
     * @note    This method will book all parts depending on their "mount_quantity".
     *          @li Example with $book_multiplier = 2:
     *              @li The "instock" of a DevicePart with "mount_quantity = 1" will be reduced by "2".
     *              @li The "instock" of a DevicePart with "mount_quantity = 4" will be reduced by "8".
     *
     * @param integer   $book_multiplier    @li if positive: the instock of the parts will be DEcreased
     *                                      @li if negative: the instock of the parts will be INcreased
     *
     * @throws Exception    if there are not enough parts in stock to book them
     * @throws Exception    if there was an error
     */
    public function bookParts(int $book_multiplier)
    {
        try {
            $transaction_id = $this->database->beginTransaction(); // start transaction
            $device_parts = $this->getParts(); // DevicePart objects

            // check if there are enought parts in stock
            foreach ($device_parts as $part) {
                /** @var DevicePart $part */
                if (($part->getMountQuantity() * $book_multiplier) > $part->getPart()->getInstock()) {
                    throw new Exception(_('Es sind nicht von allen Bauteilen genügend an Lager'));
                }
            }

            $comment = sprintf(_('Baugruppe: %s'), $this->getName());

            // OK there are enough parts in stock, we will book them
            foreach ($device_parts as $part) {
                /** @var DevicePart $part  */
                //$part->getPart()->setInstock($part->getPart()->getInstock() - ($part->getMountQuantity() * $book_multiplier));
                if ($book_multiplier > 0) {
                    $part->getPart()->withdrawalParts($part->getMountQuantity() * abs($book_multiplier), $comment);
                } else {
                    $part->getPart()->addParts($part->getMountQuantity() * abs($book_multiplier), $comment);
                }
            }

            $this->database->commit($transaction_id); // commit transaction
        } catch (Exception $e) {
            $this->database->rollback(); // rollback transaction

            // restore the settings from BEFORE the transaction
            $this->resetAttributes();

            throw new Exception(_("Die Teile konnten nicht abgefasst werden!\n") . _('Grund: ').$e->getMessage());
        }
    }

    /********************************************************************************
     *
     *   Getters
     *
     *********************************************************************************/

    /**
     *  Get the order quantity of this device
     *
     * @return integer      the order quantity
     */
    public function getOrderQuantity() : int
    {
        return (int) $this->db_data['order_quantity'];
    }

    /**
     *  Get the "order_only_missing_parts" attribute
     *
     * @return boolean      the "order_only_missing_parts" attribute
     */
    public function getOrderOnlyMissingParts() : bool
    {
        return (bool) $this->db_data['order_only_missing_parts'];
    }

    /**
     *  Get all device-parts of this device
     *
     * @note    This method overrides the same-named method of the parent class.
     * @note    The attribute "$this->parts" will be used to store the parts.
     *          (but there will be stored DevicePart-objects instead of Part-objects)
     *
     * @param boolean $recursive        if true, the parts of all subelements will be listed too
     *
     * @param int       $limit                      Limit the number of results, to this value.
     *                                              If set to 0, then the results are not limited.
     * @param int       $page                       Show the results of the page with given number.
     *                                              Use in combination with $limit.
     *
     * @return Part[]        all parts as a one-dimensional array of "DevicePart"-objects,
     *                      sorted by their names (only if "$recursive == false")
     *
     * @throws Exception if there was an error
     */
    public function getParts(bool $recursive = false, bool $hide_obsolete_and_zero = false, int $limit = 50, int $page = 1) : array
    {
        $this->current_user->tryDo(static::getPermissionName(), PartContainingPermission::LIST_PARTS);
        return $this->getPartsWithoutPermCheck($recursive, $hide_obsolete_and_zero, $limit, $page);
    }

    /**
     * Similar to getParts() but without check of the Permission.
     * For use in internal functions, like getPartsCount() or getPartsSumCount()
     * @param bool $recursive
     * @param bool $hide_obsolet_and_zero
     * @return array
     * @throws Exception
     */
    protected function getPartsWithoutPermCheck(bool $recursive = false, bool $hide_obsolet_and_zero = false, int $limit = 50, int $page = 1) : array
    {
        if (! \is_array($this->parts)) {
            $this->parts = array();

            $query =    'SELECT device_parts.* FROM device_parts '.
                'LEFT JOIN parts ON device_parts.id_part=parts.id '.
                'WHERE id_device=? ORDER BY parts.name ASC';

            $query_data = $this->database->query($query, array($this->getID()));

            foreach ($query_data as $row) {
                $this->parts[] = DevicePart::getInstance($this->database, $this->current_user, $this->log, (int) $row['id'], $row);
            }
        }

        if (! $recursive) {
            return $this->parts;
        } else {
            $parts = $this->parts;
            $subdevices = $this->getSubelements(true);

            foreach ($subdevices as $device) {
                $parts = array_merge($parts, $device->getParts(false));
            }

            return $parts;
        }
    }

    /**
     *  Get the count of different parts in this device
     *
     * This method simply returns the count of the returned array of Device::get_parts().
     *
     * @param boolean $recursive        if true, the parts of all subelements will be counted too
     *
     * @return integer      count of different parts in this device
     *
     * @throws Exception if there was an error
     */
    public function getPartsCount(bool $recursive = false) : int
    {
        $device_parts = $this->getPartsWithoutPermCheck($recursive);

        return count($device_parts);
    }

    /**
     *  Get the count of all parts in this device (every part multiplied by its quantity)
     *
     * @param boolean $recursive        if true, the parts of all subelements will be counted too
     *
     * @return integer      count of all parts in this device
     *
     * @throws Exception if there was an error
     */
    public function getPartsSumCount(bool $recursive = false) : int
    {
        $count = 0;
        $device_parts = $this->getPartsWithoutPermCheck($recursive);

        foreach ($device_parts as $device_part) {
            /** @var DevicePart $device_part */
            $count += $device_part->getMountQuantity();
        }

        return $count;
    }

    /**
     *  Get the total price of all parts in this device (counted with their mount quantity)
     *
     * @note        To calculate the price, the average prices of the parts will be used.
     *              More details: Part::get_average_price()
     *
     * @warning     If some parts don't have a price, they will be ignored!
     *              Only parts with at least one price will be counted.
     *
     * @param boolean $as_money_string      @li if true, this method will return the price as a string incl. currency
     *                                      @li if false, this method will return the price as a float
     * @param boolean $recursive            if true, the parts of all subdevicess will be counted too
     *
     * @return string       the price as a formatted string with currency (if "$as_money_string == true")
     * @return float        the price as a float (if "$as_money_string == false")
     *
     * @see floatToMoneyString()
     *
     * @throws Exception if there was an error
     */
    public function getTotalPrice(bool $as_money_string = true, bool $recursive = false)
    {
        $price = 0;
        $device_parts = $this->getPartsWithoutPermCheck($recursive);

        foreach ($device_parts as $device_part) {
            /** @var DevicePart $device_part */
            $price += $device_part->getPart()->getAveragePrice(false, $device_part->getMountQuantity());
        }

        if ($as_money_string) {
            return floatToMoneyString($price);
        } else {
            return $price;
        }
    }

    /********************************************************************************
     *
     *   Setters
     *
     *********************************************************************************/

    /**
     *  Set the order quantity
     *
     * @param integer $new_order_quantity       the new order quantity
     *
     * @throws Exception if the order quantity is not valid
     * @throws Exception if there was an error
     */
    public function setOrderQuantity(int $new_order_quantity)
    {
        $this->setAttributes(array('order_quantity' => $new_order_quantity));
    }

    /**
     *  Set the "order_only_missing_parts" attribute
     *
     * @param boolean $new_order_only_missing_parts       the new "order_only_missing_parts" attribute
     *
     * @throws Exception if there was an error
     */
    public function setOrderOnlyMissingParts(bool $new_order_only_missing_parts)
    {
        $this->setAttributes(array('order_only_missing_parts' => $new_order_only_missing_parts));
    }

    /********************************************************************************
     *
     *   Static Methods
     *
     *********************************************************************************/

    /**
     * @copydoc DBElement::check_values_validity()
     * @throws Exception
     */
    public static function checkValuesValidity(Database &$database, User &$current_user, Log &$log, array &$values, bool $is_new, &$element = null)
    {
        // first, we let all parent classes to check the values
        parent::checkValuesValidity($database, $current_user, $log, $values, $is_new, $element);

        // set the datetype of the boolean attributes
        $values['order_only_missing_parts'] = (bool)$values['order_only_missing_parts'];

        // check "order_quantity"
        if (((! \is_int($values['order_quantity'])) && (! ctype_digit($values['order_quantity'])))
            || ($values['order_quantity'] < 0)) {
            debug('error', 'order_quantity = "'.$values['order_quantity'].'"', __FILE__, __LINE__, __METHOD__);
            throw new Exception(_('Die Bestellmenge ist ungültig!'));
        }
    }

    /**
     *  Get all devices which should be ordered (marked manually as "to order")
     *
     * @param Database  &$database          reference to the database object
     * @param User      &$current_user      reference to the user which is logged in
     * @param Log       &$log               reference to the Log-object
     *
     * @return array    all devices as a one-dimensional array of Device objects, sorted by their names
     *
     * @throws Exception if there was an error
     */
    public static function getOrderDevices(Database &$database, User &$current_user, Log &$log) : array
    {
        if (!$database instanceof Database) {
            throw new Exception(_('$database ist kein Database-Objekt!'));
        }

        $devices = array();

        $query =    'SELECT * FROM devices '.
            'WHERE order_quantity > 0 '.
            'ORDER BY name ASC';

        $query_data = $database->query($query);

        foreach ($query_data as $row) {
            $devices[] = Device::getInstance($database, $current_user, $log, (int) $row['id'], $row);
        }

        return $devices;
    }

    /**
     * Gets the primary device of this session. When a device is primary, it is preselected, when the user want to add a part to an device.
     * @return null|int Null, if none or no valid value is set for a primary device. Int, the device id of the primary device.
     */
    public static function getPrimaryDevice()
    {
        if (!isset($_SESSION['primary_device'])) {
            return null;
        }
        if ($_SESSION['primary_device'] > 0) {
            return $_SESSION['primary_device'];
        } else {
            return null;
        }
    }

    /**
     * Sets the primary device.
     * @param $primary_device_id int The id of the new primary device.
     */
    public static function setPrimaryDevice(int $primary_device_id)
    {
        @session_start();
        $_SESSION['primary_device'] = $primary_device_id;
        session_write_close();
    }

    /**
     * Returns the ID as an string, defined by the element class.
     * This should have a form like P000014, for a part with ID 14.
     * @return string The ID as a string;
     */
    public function getIDString(): string
    {
        return 'D' . sprintf('%09d', $this->getID());
    }

    /**
     *  Create a new device
     *
     * @param Database  &$database                  reference to the database object
     * @param Database  &$database                  reference to the database object
     * @param User      &$current_user              reference to the current user which is logged in
     * @param Log       &$log                       reference to the Log-object
     * @param string    $name                       the name of the new device (see Device::set_name())
     * @param integer   $parent_id                  the parent ID of the new device (see Device::set_parent_id())
     *
     * @return Base\PartsContainingDBElement|Device
     *
     * @throws Exception    if (this combination of) values is not valid
     * @throws Exception    if there was an error
     *
     * @see DBElement::add()
     */
    public static function add(Database &$database, User &$current_user, Log &$log, string $name, int $parent_id, string $comment = '') : Device
    {
        return parent::addByArray(
            $database,
            $current_user,
            $log,
            array(  'name'                      => $name,
                'parent_id'                 => $parent_id,
                'order_quantity'            => 0,
                'order_only_missing_parts'  => false,
                'comment' => $comment)
        );
    }

    /**
     * Gets the permission name for control access to this StructuralDBElement
     * @return string The name of the permission for this StructuralDBElement.
     */
    protected static function getPermissionName() : string
    {
        return PermissionManager::DEVICES;
    }
}
