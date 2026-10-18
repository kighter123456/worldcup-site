<?php
/**
 * Team: 国足世界杯夺冠队
 * Coding by 李行阳 2411353, 20261018
 * 模块:用户认证 —— 用户模型
 *
 * 对应 worldcup.user 表,供前后台登录、注册与身份认证使用。
 */

namespace common\models;

use Yii;
use yii\base\NotSupportedException;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\db\Expression;
use yii\web\IdentityInterface;

/**
 * User model
 *
 * @property integer $id
 * @property string $username
 * @property string $password bcrypt 密码哈希
 * @property string|null $nickname
 * @property string|null $avatar
 * @property integer $role 0普通用户 1管理员 2超管
 * @property string $create_time
 */
class User extends ActiveRecord implements IdentityInterface
{
    const ROLE_USER = 0;
    const ROLE_ADMIN = 1;
    const ROLE_SUPER_ADMIN = 2;

    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return '{{%user}}';
    }

    /**
     * {@inheritdoc}
     */
    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'create_time',
                'updatedAtAttribute' => false,
                'value' => new Expression('NOW()'),
            ],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            ['username', 'trim'],
            ['username', 'required'],
            ['username', 'string', 'max' => 50],
            ['username', 'unique'],

            // 新建账号时必须提供密码;保存前由 setPassword() 写入哈希
            ['password', 'required', 'when' => function ($model) {
                return $model->isNewRecord;
            }],
            ['password', 'string', 'min' => 6],

            ['nickname', 'trim'],
            ['nickname', 'string', 'max' => 50],

            ['avatar', 'trim'],
            ['avatar', 'string', 'max' => 255],

            ['role', 'default', 'value' => self::ROLE_USER],
            ['role', 'in', 'range' => [self::ROLE_USER, self::ROLE_ADMIN, self::ROLE_SUPER_ADMIN]],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => '主键',
            'username' => '登录名',
            'password' => '密码',
            'nickname' => '昵称',
            'avatar' => '头像',
            'role' => '角色',
            'create_time' => '创建时间',
        ];
    }

    /**
     * {@inheritdoc}
     */
    public static function findIdentity($id)
    {
        return static::findOne($id);
    }

    /**
     * {@inheritdoc}
     */
    public static function findIdentityByAccessToken($token, $type = null)
    {
        throw new NotSupportedException('"findIdentityByAccessToken" is not implemented.');
    }

    /**
     * 按用户名查找用户
     *
     * @param string $username
     * @return static|null
     */
    public static function findByUsername($username)
    {
        return static::findOne(['username' => $username]);
    }

    /**
     * {@inheritdoc}
     */
    public function getId()
    {
        return $this->getPrimaryKey();
    }

    /**
     * {@inheritdoc}
     */
    public function getAuthKey()
    {
        return '';
    }

    /**
     * {@inheritdoc}
     */
    public function validateAuthKey($authKey)
    {
        return false;
    }

    /**
     * 校验密码
     *
     * @param string $password 待校验的明文密码
     * @return bool 密码是否正确
     */
    public function validatePassword($password)
    {
        return Yii::$app->security->validatePassword($password, $this->password);
    }

    /**
     * 生成密码哈希并写入模型
     *
     * @param string $password 明文密码
     */
    public function setPassword($password)
    {
        $this->password = Yii::$app->security->generatePasswordHash($password);
    }
}
