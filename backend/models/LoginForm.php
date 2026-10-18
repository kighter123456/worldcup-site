<?php
/**
 * Team: 国足世界杯夺冠队
 * Coding by 李行阳 2411353, 20261018
 * 模块:后台管理 —— 后台登录表单
 *
 * 在公共登录表单的基础上增加角色校验,仅管理员与超管可登录后台。
 */

namespace backend\models;

use common\models\LoginForm as BaseLoginForm;

/**
 * Backend login form
 */
class LoginForm extends BaseLoginForm
{
    /**
     * {@inheritdoc}
     */
    public function validate($attributeNames = null, $clearErrors = true)
    {
        if (!parent::validate($attributeNames, $clearErrors)) {
            return false;
        }

        $user = $this->getUser();
        if (!$user || $user->role < 1) {
            $this->addError('password', '该账号没有后台管理权限');
            return false;
        }

        return true;
    }
}
